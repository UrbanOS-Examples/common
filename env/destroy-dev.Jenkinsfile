def environment = "dev"

pipeline {
    agent any

    options {
        ansiColor('xterm')
    }
    stages {
        stage('Checkout') {
            steps {
                deleteDir()
                checkout scm
            }
        }

        stage('Destroy services') {
            options {
                timeout(time: 15, unit: 'MINUTES')
            }
            steps {
                script {
                    dir('env') {
                        sh('kubectl delete all --all || true')
                    }
                }
            }
        }

        stage('Destroy infrastructure') {
            steps {
                script {
                    dir('env') {
                        initTerraform(environment)
                        destroyEnv(environment)
                    }
                }
            }
        }
    }
}

def destroyEnv(environment) {
    def vpc_id = sh(script: "terraform output vpc_id", returnStdout: true)
    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws_jenkins_user', variable: 'AWS_ACCESS_KEY_ID']]) {
        retry(30) {
            sh("../scripts/zero_elb_count.sh ${environment} ${vpc_id}")
        }
        echo "Destroying environment attached to VPC ${vpc_id}"
        sh("terraform destroy -var-file=variables/${environment}.tfvars -auto-approve")
        sh("../scripts/delete_vpc.sh ${environment} ${vpc_id}")
    }
}

def initTerraform(environment) {
    sh("terraform init -backend-config=backends/${environment}.conf")
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
