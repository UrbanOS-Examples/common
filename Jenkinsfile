pipeline {
    agent any

    options {
        ansiColor('xterm')
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                deleteDir()
                checkout scm
            }
        }

        stage('Plan') {
            steps {
                echo 'Write out plan into Jenkins build directory for this job'
                script {
                    dir('env') {
                        def environment="dev"
                        sh("terraform init -backend-config=backends/${environment}.conf")
                        sh("terraform workspace new ${environment} || true")
                        sh("terraform workspace select ${environment}")
                        sh("set -o pipefail; terraform plan -var-file=variables/${environment}.tfvars -out plan.bin | tee -a plan.txt")
                    }
                }
            }
        }

        stage('Execute') {
            steps {
                echo "Execute terraform"
                script {
                    dir('env') {
                        sh('terraform apply plan.bin')
                    }
                }
            }
        }

        stage('Copy Kubernetes config') {
            steps {
                script {
                    dir('env') {
                        kubernetes_master_ip = sh(
                            script: 'terraform output kubernetes_master_private_ip',
                            returnStdout: true
                        ).trim()

                        withCredentials([sshUserPrivateKey(credentialsId: "k8s-no-pass", keyFileVariable: 'keyfile')]) {
                            sh("mkdir -p ~/.kube/")
                            sh("mkdir -p /var/jenkins_home/.kube")
                            sh("echo '====> WAITING FOR KUBERNETES TO START... <===='")
                            retry(24) {
                                sleep(10)
                                copyKubeConfig(kubernetes_master_ip)
                            }
                        }

                        sh("kubectl get nodes")
                    }
                }
            }
        }

        stage('Deploy Tiller') {
            steps {
                script {
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

    post {
        always {
            archiveArtifacts artifacts: 'env/plan.txt', allowEmptyArchive: false
        }
    }
}

def copyKubeConfig(kubernetes_master_ip) {
    sh("""scp -o ConnectTimeout=30 -o StrictHostKeyChecking=no -i $keyfile centos@${kubernetes_master_ip}:~/kubeconfig ~/.kube/config""")
    sh("""scp -o ConnectTimeout=30 -o StrictHostKeyChecking=no -i $keyfile centos@${kubernetes_master_ip}:~/kubeconfig /var/jenkins_home/.kube/config""")
}
