properties([
    parameters([
        string(name: 'K8_MASTER_IP', description: 'The ip address for the kubernetes master node')
    ])
])

node('master') {
    ansiColor('xterm') {
        stage('Copy kubeconfig') {
            withCredentials([sshUserPrivateKey(credentialsId: "k8s-no-pass", keyFileVariable: 'keyfile')]) {
                sh("mkdir -p ~/.kube/")
                sh("echo '====> WAITING FOR KUBERNETES TO START... <===='")
                try {
                    sh("""scp -o ConnectTimeout=30 -o StrictHostKeyChecking=no -i $keyfile centos@$K8_MASTER_IP:~/kubeconfig ~/.kube/config""")
                } catch (error) {
                    retry(2) {
                        // Wait for Kube to be up and running.
                        sleep(120)
                        sh("""scp -o ConnectTimeout=30 -o StrictHostKeyChecking=no -i $keyfile centos@$K8_MASTER_IP:~/kubeconfig ~/.kube/config""")
                    }
                }
            }
            sh("kubectl get nodes")
        }
    }
}
