library(
    identifier: 'pipeline-lib@master',
    retriever: modernSCM([$class: 'GitSCMSource',
                          remote: 'https://github.com/SmartColumbusOS/pipeline-lib',
                          credentialsId: 'jenkins-github-user'])
)

def defaultEnvironmentList = ['dev', 'staging']

properties(
    [
        disableConcurrentBuilds(),
        parameters([
            text(
                name: 'environmentsParameter',
                defaultValue: defaultEnvironmentList.join("\n"),
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
            }

            environments.each { environment ->
                stage("Plan ${environment}") {
                    plan(environment, params.alm)
                    archiveArtifacts artifacts: 'env/plan-*.txt', allowEmptyArchive: false
                }
                if (!(environment in defaultEnvironmentList) || env.BRANCH_NAME == 'master') {
                    stage("Deploy ${environment}") {
                        apply(environment)
                        createTillerUser()
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
                }
            }
        }
    }
}

def plan(environment, alm) {
    dir('env') {
        sh("""#!/usr/bin/env bash
            set -e
            set -o pipefail

            mkdir -p ~/.ssh
            public_key=\$(ssh-keygen -y -f ${keyfile})
            echo "\${public_key}" > ~/.ssh/id_rsa.pub

            extra_variables=""

            backend_file="../backends/${alm}.conf"
            if [[ ! -f \${backend_file} ]]; then
                backend_file="../backends/sandbox-alm.conf"
                extra_variables="
                \${extra_variables} \
                --var=alm_workspace=${alm}
                "
            fi

            terraform init \
                --backend-config=\${backend_file}

            terraform workspace new ${environment} || true
            terraform workspace select ${environment}

            variable_file="variables/${environment}.tfvars"
            if [[ ! -f \${variable_file} ]]; then
                variable_file="variables/sandbox.tfvars"
            fi

            terraform plan \
                --var=key_pair_public_key="\${public_key}" \
                --var=kube_key="~/.ssh/id_rsa.pub" \
                --var-file="\${variable_file}" \
                --out="plan-${environment}.bin" \
                \${extra_variables} \
                | tee -a "plan-${environment}.txt"
        """)
    }
}

def apply(environment) {
    dir('env') {
        sh("terraform apply plan-${environment}.bin")
    }
}

def createTillerUser() {
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

def applyKubeConfigs(environment) {
    scos.withEksCredentials(environment) {
        def terraformOutputs = scos.terraformOutput(environment)
        def eks_cluster_name = terraformOutputs.eks_cluster_name.value
        def aws_region = terraformOutputs.aws_region.value

        sh("""#!/bin/bash
            export EKS_CLUSTER_NAME='${eks_cluster_name}'
            export AWS_REGION='${aws_region}'

            find k8s/alb-ingress-controller -type f -exec cat {} \\; -exec echo -e '\\n---' \\; | envsubst | kubectl apply -f -
            kubectl apply -f k8s/tiller-role/
            kubectl apply -f k8s/persistent-storage/
        """.trim())
    }
}
