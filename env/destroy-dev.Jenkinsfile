node('master') {
    ansiColor('xterm') {
        stage('Checkout') {
            checkout scm
        }

        stage('Plan destruction') {
            dir('env') {
                sh('terraform init --backend-config=bucket=scos-alm-terraform-state')
                sh('terraform workspace new dev | exit 0')
                sh('terraform workspace select dev')
                sh('terraform plan -destroy -no-color -var-file=variables/dev.tfvars -out plan.bin | tee -a plan.txt')
            }
        }

        stage('Apply destruction') {
            dir('env') {
                timeout(120) {
                    sh('kubectl delete all --all || true')
                }

                retry(30) {
                    sleep(10)
                    sh("../scripts/zero_elb_count.sh")
                }

                retry(2) {
                    sh('terraform apply plan.bin')
                }
            }
        }

        archiveArtifacts artifacts: 'env/plan.txt', allowEmptyArchive: false
    }
}
