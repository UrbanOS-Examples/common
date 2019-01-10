library(
    identifier: 'pipeline-lib@smrt-817',
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
                defaultValue: '',
                description: 'The AMI for the Joomla EC2 instance snapshot to deploy'),
            string(
                name: 'joomla_backup_file_name',
                defaultValue: '',
                description: 'The backup file name in the global backups S3 bucket'),
            string(
                name: 'ckan_internal_backup_ami',
                defaultValue: '',
                description: 'The AMI for the CKAN Internal EC2 instance snapshot to deploy'),
            string(
                name: 'ckan_external_backup_ami',
                defaultValue: '',
                description: 'The AMI for the CKAN External EC2 instance snapshot to deploy'),
            string(
                name: 'ckan_db_snapshot_id',
                defaultValue: '',
                description: 'The Snapshot ID for the CKAN database to deploy'),
            string(
                name: 'kong_backup_ami',
                defaultValue: '',
                description: 'The AMI for the Kong Internal EC2 instance snapshot to deploy'),
            string(
                name: 'kong_db_snapshot_id',
                defaultValue: '',
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

node('infrastructure') { ansiColor('xterm') { sshagent(["k8s-no-pass", "GitHub"]) { withCredentials([
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
            if (isGoingToProd) {
                timeout(10) {
                    input('Apply infrastructure changes?')
                }
            }
            stage("Deploy ${environment}") {
                terraform.apply()
            }
            stage('Tag') {
                if (environment == 'staging') {
                    scos.applyAndPushGitHubTag(scos.releaseCandidateNumber())
                }

                scos.applyAndPushGitHubTag(environment)
            }
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
