node('master') {
    ansiColor('xterm') {
        stage('Deploy Infrastructure') {
            build job: 'SmartColumbusOS/common/master'
        }
        stage('Deploy Kafka') {
            build job: 'SmartColumbusOS/streaming-service/master'
        }
        stage('Deploy Streaming Services') {
            build job: 'SmartColumbusOS/cota-streaming-producer/master'
            build job: 'SmartColumbusOS/cota-streaming-consumer/master'
        }
        stage('Deploy UI') {
            build job: 'SmartColumbusOS/cota-streaming-ui/master'
        }
    }
}
