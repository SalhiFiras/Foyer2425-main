pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "salhifiras/foyer2425-main" 
        APP_PORT = "8080"
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', credentialsId: 'github-credentials', url: 'https://github.com/SalhiFiras/Foyer2425-main.git' 
            }
        }

        stage('Build Spring Boot App & Docker Image') {
            steps {
                script {
                    sh 'mvn clean package -DskipTests'
                    sh "docker build -t ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ."
                    sh "docker tag ${DOCKER_IMAGE}:${env.BUILD_NUMBER} ${DOCKER_IMAGE}:latest"
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                script {
                    sh 'mvn test'
                }
            }
        }

        stage('Deploy to VM') {
            steps {
                script {
                    sh "docker stop my-spring-boot-app || true"
                    sh "docker rm my-spring-boot-app || true"
                    sh "docker run -d -p ${APP_PORT}:${APP_PORT} --name my-spring-boot-app ${DOCKER_IMAGE}:latest"
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline successful!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}