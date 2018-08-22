library(
    identifier: 'pipeline-lib@1.3.1',
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
                description: 'Environments in which to deploy common/env'
            ),
            string(
                name: 'alm',
                defaultValue: 'alm',
                description: 'The ALM to which the common/env should attach'
            )
        ])
    ]
)

def environments = params.environmentsParameter.trim().split("\n").collect { environment ->
    environment.trim()
}

node('infrastructure') {
    ansiColor('xterm') {
        withCredentials([
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
            stage('Checkout') {
                deleteDir()
                checkout scm

                scos.addGitHubRemoteForTagging('SmartColumbusOS/common.git')
            }

            stage("Check Terraform against Prod") {

            }

            environments.each { environment ->
                stage("Plan ${environment}") {
                    plan(environment, params.alm)
                    archiveArtifacts artifacts: 'env/plan-*.txt', allowEmptyArchive: false
                }
                if (scos.shouldDeploy(environment, env.BRANCH_NAME)) {
                    stage("Deploy ${environment}") {
                        apply(environment)
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
    }
}

def plan(environment, alm) {
    dir('env') {
        def terraform = scos.terraform(environment)

        terraform.init()
        sh("""#!/usr/bin/env bash
            set -e

            mkdir -p ~/.ssh
            public_key=\$(ssh-keygen -y -f ${keyfile})
            echo "\${public_key}" > ~/.ssh/id_rsa.pub
        """)

        terraform.plan(
            key_pair_public_key: new File('~/.ssh/id_rsa.pub').text,
            kube_key: '~/.ssh/id_rsa.pub',
        )
    }
}

def apply(environment) {
    dir('env') {
        sh("terraform apply plan-${environment}.bin")
    }
}

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

            for manifest in k8s/alb-ingress-controller/*; do
                cat \$manifest | envsubst | kubectl apply -f -
            done
            kubectl apply -f k8s/tiller-role/
            kubectl apply -f k8s/persistent-storage/
        """.trim())
    }
}
