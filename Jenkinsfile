library(
    identifier: 'pipeline-lib@4.5.0',
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
                description: 'Environments in which to deploy common/env')
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
