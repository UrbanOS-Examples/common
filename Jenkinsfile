properties([disableConcurrentBuilds()])

def environment = "dev"
def kubeConfigStashName = "kubernetes-config"

node('terraform') {
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
            stage('Plan') {
                plan(environment)
            }

            if (env.BRANCH_NAME == 'master') {
                archiveArtifacts artifacts: 'env/plan.txt', allowEmptyArchive: false

                stage('Execute') {
                    execute()
                }
                // TODO - delete this stage once we move to EKS as we no longer need this config
                stage('Copy Legacy Kubernetes Config to Worker') {
                    stashLegacyKubeConfig(kubeConfigStashName)
                }
                stage('Deploy Tiller') {
                    createTillerUser()
                }
            }
        }
    }
}

// TODO - delete this stage once we move to EKS as we no longer need this config
node('master') {
    ansiColor('xterm') {
        if (env.BRANCH_NAME == 'master') {
            stage('Copy Legacy Kubernetes Config to Master') {
                unstashLegacyKubeConfig(environment, kubeConfigStashName)
                sh('kubectl get nodes')
            }
        }
    }
}

def plan(environment) {
    dir('env') {
        sh("""#!/usr/bin/env bash
            set -e
            set -o pipefail

            mkdir -p ~/.ssh
            public_key=\$(ssh-keygen -y -f ${keyfile})
            echo "\${public_key}" > ~/.ssh/id_rsa.pub

            terraform init \
                --backend-config=backends/${environment}.conf
            terraform workspace new ${environment} || true
            terraform workspace select ${environment}

            terraform plan \
                --var=key_pair_public_key="\${public_key}" \
                --var=kube_key="~/.ssh/id_rsa.pub" \
                --var-file=variables/${environment}.tfvars \
                --out=plan.bin \
                | tee -a plan.txt
        """)
    }
}

def execute() {
    dir('env') {
        sh('terraform apply plan.bin')
    }
}

def stashLegacyKubeConfig(stashName) {
    dir('env') {
        def kubernetesMasterIP = sh(
            script: 'terraform output kubernetes_master_private_ip',
            returnStdout: true
        ).trim()

        retry(24) {
            sleep(10)
            copyKubeConfig(kubernetesMasterIP, '~/.kube/config') // for tiller
            copyKubeConfig(kubernetesMasterIP, "config") // for stashing
            stash includes: 'config', name: stashName
        }
    }
}

def copyKubeConfig(kubernetesMasterIP, destinationPath) {
    sh("""#!/usr/bin/env bash
        set -e
        mkdir -p \$(dirname ${destinationPath})

        scp \
            -o ConnectTimeout=30 \
            -o StrictHostKeyChecking=no \
            -i $keyfile \
            centos@${kubernetesMasterIP}:~/kubeconfig \
            ${destinationPath}
    """)
}

def createTillerUser() {
    sh('''#!/usr/bin/env bash
        set -e
        kubectl get nodes

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

def unstashLegacyKubeConfig(environment, stashName) {
    if (environment == 'dev') {
        dir('/var/jenkins_home/.kube') {
            unstash(stashName)
        }
        dir('/root/.kube') {
            unstash(stashName)
        }
    }
    dir("/var/jenkins_home/.kube/${environment}") {
        unstash(stashName)
    }
}