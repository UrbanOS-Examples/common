node('master') {
    ansiColor('xterm') {
        stage('Checkout') {
            checkout scm
        }

        stage('Destroy') {
            dir('env') {
                sh('terraform init --backend-config=bucket=scos-alm-terraform-state')
                sh('terraform workspace new dev || true')
                sh('terraform workspace select dev')

                timeout(5) {
                    sh('kubectl delete all --all || true')
                }

                retry(30) {
                    sleep(10)
                    sh("../scripts/zero_elb_count.sh")
                }

                retry(2) {
                    sh('terraform destroy -auto-approve -no-color -var-file=variables/dev.tfvars')
                }
            }
        }
    }
}
