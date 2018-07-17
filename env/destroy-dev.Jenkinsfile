node('master') {
    ansiColor('xterm') {
        stage('Checkout') {
            deleteDir()
            checkout scm
        }

        stage('Destroy services') {
            timeout(5) {
                sh('kubectl delete all --all || true')
            }

            retry(30) {
                sleep(10)
                sh('scripts/zero_elb_count.sh')
            }
        }

        stage('Destroy infrastructure') {
            dir('env') {
                initTerraform()
                sh('terraform destroy -var-file=variables/dev.tfvars -auto-approve')
            }
        }
    }
}

def initTerraform() {
    sh('terraform init -backend-config="bucket=scos-alm-terraform-state" -backend-config="role_arn=arn:aws:iam::199837183662:role/jenkins_role" -backend-config="dynamodb_table=terraform_lock"')
    tfSwitchWorkspace()
}

def tfSwitchWorkspace() {
    try {
        sh('terraform workspace select dev')
    } catch(all) {
        sh('terraform workspace create dev')
        sh('terraform workspace select dev')
    }
}
