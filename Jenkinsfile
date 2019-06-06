pipeline {
    agent any
    stages {
        stage('build') {
            steps {
                sh 'make GLUON_TARGET=ar71xx-generic'
            }
        }
    }
}
