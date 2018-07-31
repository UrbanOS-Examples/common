properties([disableConcurrentBuilds()])

def kubernetes_master_ip
def environment = "dev"

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

            if (env.BRANCH_NAME == 'master') {
                stage('Execute') {
                    dir('env') {
                        archiveArtifacts artifacts: 'plan.txt', allowEmptyArchive: false
                        sh('terraform apply plan.bin')

                        kubernetes_master_ip = sh(
                            script: 'terraform output kubernetes_master_private_ip',
                            returnStdout: true
                        ).trim()
                    }
                }
                // TODO - delete the copyConfig part of this when we move to EKS
                stage('Configure Legacy K8s Cluster') {
                    retry(24) {
                        sleep(10)
                        copyKubeConfig(kubernetes_master_ip, '~/.kube/config')
                        copyKubeConfig(kubernetes_master_ip, "${env.WORKSPACE}/config")
                        stash includes: 'config', name: 'kubernetes-config'
                    }

                    createTillerUser()
                }

            }
        }
    }
}

// TODO - delete this once we move to EKS as we no longer need this config
node('master') {
    if (env.BRANCH_NAME == 'master') {
        stage('Copy Legacy K8S Config to Master') {
            dir('/var/jenkins_home/.kube') {
                unstash('kubernetes-config')
            }
            dir('/root/.kube') {
                unstash('kubernetes-config')
            }
            sh('kubectl get nodes')
        }
    }
}

def copyKubeConfig(kubernetes_master_ip, destination_path) {
    sh("""#!/usr/bin/env bash
        set -e
        mkdir -p \$(dirname ${destination_path})

        scp \
            -o ConnectTimeout=30 \
            -o StrictHostKeyChecking=no \
            -i $keyfile \
            centos@${kubernetes_master_ip}:~/kubeconfig \
            ${destination_path}
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