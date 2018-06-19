node('master') {
    ansiColor('xterm') {
        stage('Checkout') {
            checkout scm
            echo 'Checkout from GIT'
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
        archiveArtifacts artifacts: 'output/plan.txt, output/plan.bin', allowEmptyArchive: true
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
        archiveArtifacts artifacts: 'output/destroy.txt, output/apply.txt', allowEmptyArchive: true
    }
}