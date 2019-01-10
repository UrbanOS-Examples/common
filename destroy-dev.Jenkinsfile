node('master') {
    def environment = "dev"
    ansiColor('xterm') {
        stage('Checkout') {
            deleteDir()
            checkout scm
        }

        stage('Destroy services') {
            dir('env') {
                timeout(15) {
                    sh('kubectl delete all --all || true')
                }
            }
        }

        stage('Destroy infrastructure') {
            dir('env') {
                initTerraform(environment)
                destroyEnv(environment)
            }
        }
    }
}

def destroyEnv(environment) {
    def vpc_id = sh(script: "terraform output vpc_id", returnStdout: true)
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws_jenkins_user', variable: 'AWS_ACCESS_KEY_ID']]) {
        echo "Destroying environment attached to VPC ${vpc_id}"
        sh("terraform destroy -var-file=variables/${environment}.tfvars -auto-approve")
    }
}

def initTerraform(environment) {
    sh("terraform init -backend-config=../backends/alm.conf")
    tfSwitchWorkspace(environment)
}

def tfSwitchWorkspace(environment) {
    try {
        sh("terraform workspace select ${environment}")
    } catch(all) {
        sh("terraform workspace create ${environment}")
        sh("terraform workspace select ${environment}")
    }
}
