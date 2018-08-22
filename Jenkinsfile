library(
    identifier: 'pipeline-lib@1.4.0',
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
        String publicKey, publicKeyFileName

            stage('Checkout') {
                deleteDir()
                checkout scm

                scos.addGitHubRemoteForTagging('SmartColumbusOS/common.git')
            }

            dir('env') {
                stage('Setup SSH keys') {
                    publicKey = sh(returnStdout: true, script: "ssh-keygen -y -f ${keyfile}").trim()
                }

                if (scos.shouldDeploy('dev', env.BRANCH_NAME)) {
                    def terraform = scos.terraform('prod-prime')

                    stage('Checkout current prod code') {
                        scos.addGitHubRemoteForTagging('common')
                        sh 'git fetch github --tags && git checkout prod'
                    }

                    stage('Create Ephemeral Prod In Dev') {
                        terraform.init()

                        terraform.plan(
                            'key_pair_public_key': publicKey
                        )
                        terraform.apply()
                    }

                    stage('Return to current git revision') {
                        checkout scm
                    }

                    try {
                        stage('Apply to ephemeral prod') {
                            terraform.plan(
                                'key_pair_public_key': publicKey
                            )
                            terraform.apply()
                        }
                    } finally {
                        stage('Destroy ephemeral prod') {
                            terraform.destroy()
                        }
                    }
                }

                environments.each { environment ->
                    def terraform = scos.terraform(environment)

                    stage("Plan ${environment}") {
                        terraform.init()

                        terraform.plan(
                            'key_pair_public_key': publicKey
                        )

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
        }
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
