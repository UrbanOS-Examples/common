node('master') {
    ansiColor('xterm') {
        stage('Deploy Infrastructure') {
            build job: 'common'
        }
        stage('Deploy Kafka') {
            build job: 'streaming-service'
        }
        stage('Deploy Streaming Services') {
            build job: 'deploy-cota-streaming-producer'
            build job: 'deploy-cota-streaming-consumer'
        }
        stage('Deploy UI') {
            build job: 'deploy-cota-streaming-ui'
        }
    }
}
