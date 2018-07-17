node('master') {
    properties([disableConcurrentBuilds()])

    ansiColor('xterm') {
        stage('Checkout') {
            deleteDir()
            checkout scm
        }

        stage('Plan') {
            echo 'Write out plan into Jenkins build directory for this job'
            dir('env') {
                sh('terraform init -backend-config="bucket=scos-alm-terraform-state" -backend-config="role_arn=arn:aws:iam::199837183662:role/jenkins_role" -backend-config="dynamodb_table=terraform_lock"')
                sh('terraform workspace new dev || exit 0')
                sh('terraform workspace select dev')
                sh('set -o pipefail; terraform plan -var-file=variables/dev.tfvars -out ../output/plan.bin  | tee -a ../output/plan.txt')
            }
        }

        archiveArtifacts artifacts: 'output/plan.txt', allowEmptyArchive: false

        stage('Execute') {
            echo "Execute terraform"
            dir('env') {
                sh('terraform apply ../output/plan.bin')
            }
        }

        stage('Copy Kubernetes config') {
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

def copyKubeConfig(kubernetes_master_ip) {
    sh("""scp -o ConnectTimeout=30 -o StrictHostKeyChecking=no -i $keyfile centos@${kubernetes_master_ip}:~/kubeconfig ~/.kube/config""")
    sh("""scp -o ConnectTimeout=30 -o StrictHostKeyChecking=no -i $keyfile centos@${kubernetes_master_ip}:~/kubeconfig /var/jenkins_home/.kube/config""")
}
