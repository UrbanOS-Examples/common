library(
    identifier: 'pipeline-lib@3.0.1',
    retriever: modernSCM([$class: 'GitSCMSource',
                          remote: 'https://github.com/SmartColumbusOS/pipeline-lib',
                          credentialsId: 'jenkins-github-user'])
)

properties(
    [
        disableConcurrentBuilds(),
        parameters([
            text(
                name: 'environmentsParameter',
                defaultValue: scos.environments().join("\n"),
                description: 'Environments in which to deploy common/env'),
            string(
                name: 'joomlaBackupAMI',
                defaultValue: 'ami-09f6adc22771a71fa',
                description: 'The AMI for the Joomla EC2 instance snapshot to deploy'),
            string(
                name: 'joomlaBackupFileName',
                defaultValue: 'site-www.smartcolumbusos.com-20180829-200003edt.zip',
                description: 'The backup file name in the global backups S3 bucket'),
            string(
                name: 'ckanInternalBackupAMI',
                defaultValue: 'ami-0d34a796e1323e492',
                description: 'The AMI for the CKAN Internal EC2 instance snapshot to deploy'),
            string(
                name: 'ckanExternalBackupAMI',
                defaultValue: 'ami-0d02a518404951549',
                description: 'The AMI for the CKAN External EC2 instance snapshot to deploy'),
            string(
                name: 'ckanDBSnapshotID',
                defaultValue: 'arn:aws:rds:us-west-2:068920858268:snapshot:ckan-92b73cc8e5540bee9c9fb11fe9cd988e3d9b6f24',
                description: 'The Snapshot ID for the CKAN database to deploy'),
            string(
                name: 'kongBackupAMI',
                defaultValue: 'ami-0acc9642a39710355',
                description: 'The AMI for the Kong Internal EC2 instance snapshot to deploy'),
            string(
                name: 'kongDBSnapshotID',
                defaultValue: 'arn:aws:rds:us-west-2:374013108165:snapshot:prod-kong-0-13-1-2018-08-29-07-20',
                description: 'The Snapshot ID for the Kong database to deploy')
        ])
    ]
)

def environments = params.environmentsParameter.trim().split("\n").collect { environment ->
    environment.trim()
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
    String publicKey

    scos.doCheckoutStage()

    dir('env') {
        stage('Setup SSH keys') {
            publicKey = sh(returnStdout: true, script: "ssh-keygen -y -f ${keyfile}").trim()
        }

        if (scos.shouldDeploy('dev', env.BRANCH_NAME)) {
            def terraform = scos.terraform('prod-prime')
            def gitHash

            stage('Checkout current prod code') {
                gitHash = sh(returnStdout: true, script: 'git rev-parse HEAD')

                sh 'git fetch github --tags && git checkout prod'
            }

            try {
                stage('Create Ephemeral Prod In Dev') {
                    terraform.init()

                    terraform.plan('variables/dev.tfvars', [
                        'key_pair_public_key': publicKey,
                        'vpc_cidr': '10.201.0.0/16',
                        'joomla_backup_ami': params.joomlaBackupAMI,
                        'joomla_backup_file_name': params.joomlaBackupFileName,
                        'ckan_internal_backup_ami': params.ckanInternalBackupAMI,
                        'ckan_external_backup_ami': params.ckanExternalBackupAMI,
                        'ckan_db_snapshot_id': params.ckanDBSnapshotID,
                        'kong_backup_ami': params.kongBackupAMI,
                        'kong_db_snapshot_id': params.kongDBSnapshotID,

                        // The following are dead after this code makes it to prod
                        'kubernetes_cluster_name': 'streaming-kube-prod-prime'
                    ])
                    terraform.apply()
                }

                stage('Return to current git revision') {
                    sh "git checkout ${gitHash}"
                }

                stage('Apply to ephemeral prod') {
                    terraform.init()
                    terraform.plan('variables/dev.tfvars', [
                        'key_pair_public_key': publicKey,
                        'vpc_cidr': '10.201.0.0/16',
                        'joomla_backup_ami': params.joomlaBackupAMI,
                        'joomla_backup_file_name': params.joomlaBackupFileName,
                        'ckan_internal_backup_ami': params.ckanInternalBackupAMI,
                        'ckan_external_backup_ami': params.ckanExternalBackupAMI,
                        'ckan_db_snapshot_id': params.ckanDBSnapshotID,
                        'kong_backup_ami': params.kongBackupAMI,
                        'kong_db_snapshot_id': params.kongDBSnapshotID
                    ])
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

            stage("Plan ${environment}") {
                terraform.init()

                terraform.plan(terraform.defaultVarFile, [
                    'key_pair_public_key': publicKey,
                    'joomla_backup_ami': params.joomlaBackupAMI,
                    'joomla_backup_file_name': params.joomlaBackupFileName,
                    'ckan_internal_backup_ami': params.ckanInternalBackupAMI,
                    'ckan_external_backup_ami': params.ckanExternalBackupAMI,
                    'ckan_db_snapshot_id': params.ckanDBSnapshotID,
                    'kong_backup_ami': params.kongBackupAMI,
                    'kong_db_snapshot_id': params.kongDBSnapshotID
                ])

                archiveArtifacts artifacts: 'plan-*.txt', allowEmptyArchive: false
            }
            if (scos.shouldDeploy(environment, env.BRANCH_NAME)) {
                stage("Deploy ${environment}") {
                    terraform.apply()
                    createTillerUser(environment)
                }
                stage("Execute Kubernetes Configs for ${environment}") {
                    applyKubeConfigs(environment)
                }
                stage("Deploy tiller service for ${environment}") {
                    scos.withEksCredentials(environment) {
                        sh('''#!/usr/bin/env bash
                            set -e
                            helm init --service-account tiller
                        ''')
                    }
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
}}}}

def createTillerUser(environment) {
    scos.withEksCredentials(environment) {
        /* Assumes this is running on the infrastructure node */
        sh('''#!/usr/bin/env bash
            set -e

            if [ $(kubectl get serviceaccount \
                    --namespace kube-system \
                    | grep -wc tiller) -eq 0 ]; then

                kubectl create serviceaccount tiller \
                    --namespace kube-system
            fi
            if [ $(kubectl get clusterrolebinding \
                    --namespace kube-system \
                    | grep -wc tiller) -eq 0 ]; then

                kubectl create clusterrolebinding tiller \
                    --clusterrole cluster-admin \
                    --serviceaccount=kube-system:tiller
            fi
        ''')
    }
}

def applyKubeConfigs(environment) {
    scos.withEksCredentials(environment) {
        def terraformOutputs = scos.terraformOutput(environment)
        def eks_cluster_name = terraformOutputs.eks_cluster_name.value
        def aws_region = terraformOutputs.aws_region.value

        sh("""#!/bin/bash
            export EKS_CLUSTER_NAME='${eks_cluster_name}'
            export AWS_REGION='${aws_region}'
            export DNS_ZONE='${environment}.internal.smartcolumbusos.com'

            for manifest in k8s/alb-ingress-controller/*; do
                cat \$manifest | envsubst | kubectl apply -f -
            done
            kubectl apply -f k8s/tiller-role/
            kubectl apply -f k8s/persistent-storage/
            kubectl apply -f k8s/external-dns/
        """.trim())
    }
}
