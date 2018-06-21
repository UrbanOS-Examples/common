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
                sh("echo Kubernetes Master IP: ${kubernetes_master_ip}")
                build job: 'kubeconfig', parameters: [string(name: 'K8_MASTER_IP', value: kubernetes_master_ip)]
            }
        }
    }
}
