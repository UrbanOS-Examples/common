node('master') {
    properties([disableConcurrentBuilds()])

    ansiColor('xterm') {
        stage('Checkout') {
            checkout scm
        }

        stage('Plan') {
            echo 'Write out plan into Jenkins build directory for this job'
            dir('env') {
                sh('rm -rf .terraform output | exit 0')
                sh('terraform init -backend-config="bucket=scos-alm-terraform-state"')
                sh('terraform workspace new dev || exit 0')
                sh('terraform workspace select dev')
                sh('echo name: $JOB_NAME - build number: $BUILD_NUMBER | tee ../output/plan.txt')
                sh('echo "---------------------------------------------" | tee -a ../output/plan.txt')
                sh('terraform plan -var-file=variables/dev.tfvars -out ../output/plan.bin  | tee -a ../output/plan.txt')
            }
        }

        archiveArtifacts artifacts: 'output/plan.txt', allowEmptyArchive: false

        stage('Execute') {
            echo "Execute terraform"
            dir('env') {
                sh('echo name: $JOB_NAME - build number: $BUILD_NUMBER | tee ../output/apply.txt')
                sh('echo "---------------------------------------------" | tee -a ../output/apply.txt')
                sh('echo "---- Applying updates:      DEV        ------" | tee -a ../output/apply.txt')
                sh('echo "---------------------------------------------" | tee -a ../output/apply.txt')
                sh('terraform apply ../output/plan.bin                   | tee -a ../output/apply.txt')
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

def copyKubeConfig(kubernetes_master_ip) {
    sh("""scp -o ConnectTimeout=30 -o StrictHostKeyChecking=no -i $keyfile centos@${kubernetes_master_ip}:~/kubeconfig ~/.kube/config""")
}