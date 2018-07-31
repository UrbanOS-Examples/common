def scmVars

node('master') {
    properties([disableConcurrentBuilds()])

    ansiColor('xterm') {
        stage('Checkout') {
            deleteDir()
            scmVars = checkout scm
        }

        stage('Plan') {
            plan("dev")
        }

        if (scmVars.GIT_BRANCH == 'master') {
            archiveArtifacts artifacts: 'env/plan.txt', allowEmptyArchive: false

            stage('Execute') {
                execute()
            }

            stage('Copy Kubernetes config') {
                copyKubeConfig("dev")
            }

            stage('Deploy Tiller') {
                dir('env') {
                    sh('''
                        if [ $(kubectl get serviceaccount --namespace kube-system | grep -wc tiller) -eq 0 ]; then
                            kubectl --namespace kube-system create serviceaccount tiller
                        fi
                    ''')
                    sh('''
                        if [ $(kubectl get clusterrolebinding --namespace kube-system | grep -wc tiller) -eq 0 ]; then
                            kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
                        fi
                    ''')
                }
            }
        }
    }
}

def plan(environment) {
    echo "Write out plan into Jenkins build directory for ${environment}."
    dir('env') {
        sh("terraform init -backend-config=backends/${environment}.conf")
        sh("terraform workspace new ${environment} || true")
        sh("terraform workspace select ${environment}")
        sh("set -o pipefail; terraform plan -var-file=variables/${environment}.tfvars -out plan.bin | tee -a plan.txt")
    }
}

def execute() {
    echo "Execute terraform"
    dir('env') {
        sh('terraform apply plan.bin')
    }
}

def copyKubeConfig(environment) {
    dir('env') {
        kubernetes_master_ip = sh(
            script: 'terraform output kubernetes_master_private_ip',
            returnStdout: true
        ).trim()

        withCredentials([sshUserPrivateKey(credentialsId: "k8s-no-pass", keyFileVariable: 'keyfile')]) {
            sh("mkdir -p ~/.kube/")
            sh("mkdir -p /var/jenkins_home/.kube")
            sh("mkdir -p /var/jenkins_home/.kube/${environment}")
            sh("echo '====> WAITING FOR KUBERNETES TO START... <===='")
            retry(24) {
                sleep(10)
                if (environment == "dev") {
                    sh("""scp -o ConnectTimeout=30 -o StrictHostKeyChecking=no -i $keyfile centos@${kubernetes_master_ip}:~/kubeconfig ~/.kube/config""")
                    sh("""scp -o ConnectTimeout=30 -o StrictHostKeyChecking=no -i $keyfile centos@${kubernetes_master_ip}:~/kubeconfig /var/jenkins_home/.kube/config""")
                }

                sh("""scp -o ConnectTimeout=30 -o StrictHostKeyChecking=no -i $keyfile centos@${kubernetes_master_ip}:~/kubeconfig /var/jenkins_home/.kube/${environment}/config""")
            }
        }

        sh("kubectl get nodes")
    }
}
