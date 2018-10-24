library(
    identifier: 'pipeline-lib@4.3.5',
    retriever: modernSCM([$class: 'GitSCMSource',
                          remote: 'https://github.com/SmartColumbusOS/pipeline-lib',
                          credentialsId: 'jenkins-github-user'])
)

properties(
    [
        pipelineTriggers([scos.dailyBuildTrigger()]),
        disableConcurrentBuilds(),
        parameters([
            booleanParam(
                name: 'skipBuild',
                defaultValue: true,
                description: 'Leave true to generate parameters for production releases without executing the entire job.'),
            text(
                name: 'environmentsParameter',
                defaultValue: scos.environments().join("\n"),
                description: 'Environments in which to deploy common/env'),
            string(
                name: 'joomla_backup_ami',
                defaultValue: 'ami-05c3ff4f743a1dd71',
                description: 'The AMI for the Joomla EC2 instance snapshot to deploy'),
            string(
                name: 'joomla_backup_file_name',
                defaultValue: '',
                description: 'The backup file name in the global backups S3 bucket'),
            string(
                name: 'ckan_internal_backup_ami',
                defaultValue: 'ami-0f157ced15f5ad29d',
                description: 'The AMI for the CKAN Internal EC2 instance snapshot to deploy'),
            string(
                name: 'ckan_external_backup_ami',
                defaultValue: 'ami-0124f020e940d4a10',
                description: 'The AMI for the CKAN External EC2 instance snapshot to deploy'),
            string(
                name: 'ckan_db_snapshot_id',
                defaultValue: '',
                description: 'The Snapshot ID for the CKAN database to deploy'),
            string(
                name: 'kong_backup_ami',
                defaultValue: 'ami-0eea495ff529dec4e',
                description: 'The AMI for the Kong Internal EC2 instance snapshot to deploy'),
            string(
                name: 'kong_db_snapshot_id',
                defaultValue: 'arn:aws:rds:us-west-2:374013108165:snapshot:prod-kong-0-13-1-2018-08-29-07-20',
                description: 'The Snapshot ID for the Kong database to deploy')
        ])
    ]
)

def environments = params.environmentsParameter.trim().split("\n").collect { environment ->
    environment.trim()
}

def terraformOverrides = params.findAll { key, value ->
    key != "environmentsParameter" && key != "skipBuild" && value != ""
}

node('infrastructure') { ansiColor('xterm') { sshagent(["k8s-no-pass"]) { withCredentials([
    [
        $class: 'AmazonWebServicesCredentialsBinding',
        credentialsId: 'aws_jenkins_user',
        variable: 'AWS_ACCESS_KEY_ID'
    ],
    sshUserPrivateKey(
        credentialsId: "k8s-no-pass",
        keyFileVariable: 'keyfile'
    )
]) {

    if(params.skipBuild && scos.changeset.isRelease) {
        currentBuild.result = 'ABORTED'
        error('Build skipped per "skipBuild" parameter.')
    }

    String publicKey

    scos.doCheckoutStage()

    dir('env') {
        stage('Setup SSH keys') {
            publicKey = sh(returnStdout: true, script: "ssh-keygen -y -f ${keyfile}").trim()
        }

        if (false && scos.changeset.shouldDeploy('dev')) {
            def terraform = scos.terraform('prod-prime')
            def gitHash

            stage('Checkout current prod code') {
                gitHash = sh(returnStdout: true, script: 'git rev-parse HEAD')

                sh 'git fetch github --tags && git checkout prod'
            }

            try {
                stage('Create Ephemeral Prod In Dev') {
                    terraform.init()

                    def overrides = [:]
                    overrides << terraformOverrides
                    overrides << [
                        'key_pair_public_key': publicKey,
                        'vpc_cidr': '10.201.0.0/16',
                        // The following are dead after this code makes it to prod
                        'kubernetes_cluster_name': 'streaming-kube-prod-prime'
                    ]

                    terraform.plan('variables/dev.tfvars', overrides)
                    terraform.apply()
                }

                stage('Return to current git revision') {
                    sh "git checkout ${gitHash}"
                }

                stage('Apply to ephemeral prod') {
                    terraform.init()

                    def overrides = [:]
                    overrides << terraformOverrides
                    overrides << [
                        'key_pair_public_key': publicKey,
                        'vpc_cidr': '10.201.0.0/16'
                    ]

                    terraform.plan('variables/dev.tfvars', overrides)
                    terraform.apply()
                }
            } finally {
                stage('Destroy ephemeral prod') {
                    terraform.planDestroy('variables/dev.tfvars')
                    terraform.apply()
                }
            }
        }

        environments.each { environment ->
            def terraform = scos.terraform(environment)

            def isGoingToProd = (scos.changeset.isRelease && environment == 'prod')
            def shouldBePlanned = (!scos.changeset.isRelease || isGoingToProd)

            if(shouldBePlanned) {
                doPlan(terraform, environment, publicKey, terraformOverrides)
            }

            if (scos.changeset.shouldDeploy(environment)) {
                stage("Deploy ${environment}") {
                    terraform.apply()
                }
                stage("Deploy tiller service for ${environment}") {
                    createTillerService(environment)
                }
                stage("Execute infrastructure Helm charts for ${environment}") {
                    applyInfraHelmCharts(environment)
                }
                stage('Tag') {
                    if (environment == 'staging') {
                        scos.applyAndPushGitHubTag(scos.releaseCandidateNumber())
                    }

                    scos.applyAndPushGitHubTag(environment)
                }
            }
        }
    }
    scos.doStageIf(scos.changeset.shouldDeploy('prod'), 'Apply Prod specific infrastructure') {
        dir('prod') {
            def terraform = scos.terraform('prod')
            terraform.init()
            terraform.plan(terraform.defaultVarFile)
            terraform.apply()
        }
    }
}}}}

def doPlan(terraform, environment, publicKey, terraformOverrides) {
    stage("Plan ${environment}") {
        terraform.init()

        def overrides = [:]
        overrides << terraformOverrides
        overrides << [ 'key_pair_public_key': publicKey ]

        terraform.plan(terraform.defaultVarFile, overrides)

        archiveArtifacts artifacts: 'plan-*.txt', allowEmptyArchive: false
    }
}

def createTillerService(environment) {
    scos.withEksCredentials(environment) {
        /* Assumes this is running on the infrastructure node */
        sh('''#!/usr/bin/env bash
            set -e

            kubectl apply -f k8s/tiller-role/

            helm init --service-account tiller
        ''')
    }
}

def applyInfraHelmCharts(environment) {
    scos.withEksCredentials(environment) {
        def terraformOutputs = scos.terraformOutput(environment)
        def eks_cluster_name = terraformOutputs.eks_cluster_name.value
        def aws_region = terraformOutputs.aws_region.value
        def subnets = terraformOutputs.public_subnets.value.join(', ')
        def albToClusterSG = terraformOutputs.allow_all_security_group.value

        sh("""#!/bin/bash
            export EKS_CLUSTER_NAME="${eks_cluster_name}"
            export AWS_REGION="${aws_region}"
            export DNS_ZONE="${environment}.internal.smartcolumbusos.com"
            export SUBNETS="${subnets}"
            export SECURITY_GROUPS="${albToClusterSG}"

            for i in \$(seq 1 5); do
                [ \$i -gt 1 ] && sleep 15
                [ \$(kubectl get pods --namespace kube-system -l name='tiller' | grep -ic Running) -gt 0 ] && break
                echo "Running Tiller Pod not found"
                [ \$i -eq 5 ] && exit 1
            done

            # label the dns namespace to later select for network policy rules; overwrite = no-op
            kubectl get namespaces | egrep '^cluster-infra ' || kubectl create namespace cluster-infra
            kubectl label namespace cluster-infra name=cluster-infra --overwrite

            helm upgrade --install cluster-infra helm/cluster-infra \
                --namespace=cluster-infra \
                --set externalDns.args."domain\\-filter"="\${DNS_ZONE}" \
                --set albIngress.extraEnv."AWS\\_REGION"="\${AWS_REGION}" \
                --set albIngress.extraEnv."CLUSTER\\_NAME"="\${EKS_CLUSTER_NAME}" \
                --values helm/cluster-infra/run-config.yaml

        """.trim())
    }
}
