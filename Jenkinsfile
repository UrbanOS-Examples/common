def defaultEnvironmentList = ['dev', 'staging']
def kubeConfigStashName = "kubernetes-config"

properties(
    [
        disableConcurrentBuilds(),
        parameters([
            text(
                name: 'environmentsParameter',
                defaultValue: defaultEnvironmentList.join("\n"),
                description: 'Environments in which to deploy common/env'
            ),
            string(
                name: 'alm',
                defaultValue: 'alm',
                description: 'The ALM to which the common/env should attach'
            )
        ])
    ]
)

def environments = environmentsParameter.trim().split("\n").collect({ environment ->
    environment.trim()
})

node('terraform') {
    ansiColor('xterm') {
        withCredentials([
            [
                $class: 'AmazonWebServicesCredentialsBinding',
                credentialsId: 'aws_jenkins_user',
                variable: 'AWS_ACCESS_KEY_ID'
            ],
            sshUserPrivateKey(
                credentialsId: "k8s-no-pass",
                keyFileVariable: 'keyfile'
            )
        ]) {
            stage('Checkout') {
                deleteDir()
                checkout scm
            }

            environments.each({ environment ->
                def eksConfiguration = "${environment}_kubeconfig"

                stage("Plan ${environment}") {
                    plan(environment, alm)
                    archiveArtifacts artifacts: 'env/plan-*.txt', allowEmptyArchive: false
                }
                if (!(environment in defaultEnvironmentList) || env.BRANCH_NAME == 'master') {
                    stage("Deploy ${environment}") {
                        execute(environment)
                        stashLegacyKubeConfig(buildStashName(kubeConfigStashName, environment))
                        createTillerUser()
                        getEksKubeConfig(eksConfiguration)
                        withEnv(["KUBECONFIG=./${eksConfiguration}"]) {
                            createTillerUser()
                        }
                    }
                    stage("Execute Kubernetes Configs for ${environment}") {
                        applyKubeConfigs()
                    }
                }
            })
        }
    }
}

// TODO - delete this stage once we move to EKS as we no longer need this config
node('master') {
    ansiColor('xterm') {
        environments.each({ environment ->
            if (!(environment in defaultEnvironmentList) || env.BRANCH_NAME == 'master') {
                stage("Copy Legacy Kubernetes Config to Master for ${environment}") {
                    unstashLegacyKubeConfig(environment, buildStashName(kubeConfigStashName, environment))
                }
            }
        })
    }
}

def plan(environment, alm) {
    dir('env') {
        sh("""#!/usr/bin/env bash
            set -e
            set -o pipefail

            mkdir -p ~/.ssh
            public_key=\$(ssh-keygen -y -f ${keyfile})
            echo "\${public_key}" > ~/.ssh/id_rsa.pub

            extra_variables=""

            backend_file="../backends/${alm}.conf"
            if [[ ! -f \${backend_file} ]]; then
                backend_file="../backends/sandbox-alm.conf"
                extra_variables="
                \${extra_variables} \
                --var=alm_workspace=${alm}
                "
            fi

            terraform init \
                --backend-config=\${backend_file}

            terraform workspace new ${environment} || true
            terraform workspace select ${environment}

            variable_file="variables/${environment}.tfvars"
            if [[ ! -f \${variable_file} ]]; then
                variable_file="variables/sandbox.tfvars"
                extra_variables="
                \${extra_variables} \
                --var="vpc_cidr="
                "
            fi

            terraform plan \
                --var=key_pair_public_key="\${public_key}" \
                --var=kube_key="~/.ssh/id_rsa.pub" \
                --var-file="\${variable_file}" \
                --out="plan-${environment}.bin" \
                \${extra_variables} \
                | tee -a "plan-${environment}.txt"
        """)
    }
}

def execute(environment) {
    dir('env') {
        sh("terraform apply plan-${environment}.bin")
    }
}

def buildStashName(stashName, environment) {
    "${stashName}-${environment}"
}

def stashLegacyKubeConfig(stashName) {
    dir('env') {
        def kubernetesMasterIP = sh(
            script: 'terraform output kubernetes_master_private_ip',
            returnStdout: true
        ).trim()

        retry(24) {
            sleep(10)
            copyKubeConfig(kubernetesMasterIP, '~/.kube/config') // for tiller
            copyKubeConfig(kubernetesMasterIP, "config") // for stashing
            stash includes: 'config', name: stashName
        }
    }
}

def copyKubeConfig(kubernetesMasterIP, destinationPath) {
    sh("""#!/usr/bin/env bash
        set -e
        mkdir -p \$(dirname ${destinationPath})

        scp \
            -o ConnectTimeout=30 \
            -o StrictHostKeyChecking=no \
            -i $keyfile \
            centos@${kubernetesMasterIP}:~/kubeconfig \
            ${destinationPath}
    """)
}

def getEksKubeConfig(config_file) {
    dir('env') {
        sh("""#!/usr/bin/env bash
            set -e
            terraform output eks-cluster-kubeconfig > ../$config_file
        """)
    }
}


def createTillerUser() {
    /* Assumes this is running on the terraform node */
    sh('''#!/usr/bin/env bash
        set -e

        if [ $(kubectl get serviceaccount \
                --namespace kube-system \
                | grep -wc tiller) -eq 0 ]; then

            kubectl create serviceaccount tiller \
                --namespace kube-system
        fi
        if [ $(kubectl get clusterrolebinding \
                --namespace kube-system \
                | grep -wc tiller) -eq 0 ]; then

            kubectl create clusterrolebinding tiller \
                --clusterrole cluster-admin \
                --serviceaccount=kube-system:tiller
        fi
    ''')
}

def unstashLegacyKubeConfig(environment, stashName) {
    dir("/var/jenkins_home/.kube/${environment}") {
        unstash(stashName)
    }

    sh("KUBECONFIG=/var/jenkins_home/.kube/${environment}/config kubectl get nodes")
}

def applyKubeConfigs() {
    sh('''#!/usr/bin/env bash
        set -e
        cd env/
        eks_cluster_name=$(terraform output eks_cluster_name)
        aws_region=$(terraform output aws_region)
        terraform output eks-cluster-kubeconfig > /tmp/eks-cluster-kubeconfig
        cd ../
        sed -ie "s/%CLUSTER_NAME%/$eks_cluster_name/" k8s/alb-ingress-controller/03-deployment.yaml
        sed -ie "s/%AWS_REGION%/$aws_region/" k8s/alb-ingress-controller/03-deployment.yaml
        kubectl apply --kubeconfig=/tmp/eks-cluster-kubeconfig -f k8s/alb-ingress-controller/
    ''')
}
