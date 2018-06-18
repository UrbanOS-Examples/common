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
              sh("""scp -o StrictHostKeyChecking=no -i $keyfile centos@$K8_MASTER_IP:~/kubeconfig ~/.kube/config""")
              sh("kubectl get all")
          }
        }
    }
}
