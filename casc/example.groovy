pipeline {
    agent { label 'go' }
    stages {
        stage('Clone Repository') {
            steps {
                git "https://github.com/buildkite/golang-example"
            }
        }
        stage('Static Code Analysis') {
            steps {
                echo 'placeholder for sonar'
            }
        }
        stage('Download Dependencies') {
            steps {
                container('go') {
                    sh 'go get -t -d github.com/buildkite/golang-example'
                }          
            }
        }
        stage('Unit Test') {
            steps {
                container('go') {
                    sh 'go test'
                }
            }
        }
        stage('Build') {
            steps {
                container('go') {
                    sh 'go build'
                }
            }
        }
        stage('Push Package') {
            steps {
                echo 'placeholder for push to artifactory'
            }
        }
    }
}