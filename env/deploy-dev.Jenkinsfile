pipeline {
    agent any

    options {
        ansiColor('xterm')
    }

    stages {
       stage('Deploy Infrastructure') {
            steps {
                build job: 'SmartColumbusOS/common/master'
            }
        }
        stage('Deploy Kafka') {
            steps {
                build job: 'SmartColumbusOS/streaming-service/master'
            }
        }
        stage('Deploy Streaming Services') {
            steps {
                build job: 'SmartColumbusOS/cota-streaming-producer/master'
                build job: 'SmartColumbusOS/cota-streaming-consumer/master'
            }
        }
        stage('Deploy UI') {
            steps {
                build job: 'SmartColumbusOS/cota-streaming-ui/master'
            }
        }
    }
}
