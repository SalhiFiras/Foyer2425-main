pipeline {
    agent any

    environment {
        DOCKER_HUB_USERNAME = 'salhifiras'
        IMAGE_NAME = 'foyer2425-main'
        APP_NAME = 'my-spring-boot-app'
        HOST_PORT = 8081 // Host port for the Spring Boot application (to avoid conflict with Jenkins)
        CONTAINER_PORT = 8080 // Internal port of the Spring Boot application
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    echo 'Checking out SCM...'
                    checkout scm
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                script {
                    echo 'Running Maven Unit Tests...'
                    docker.image('maven:3.8.5-openjdk-17').inside {
                        sh 'mvn clean install -DskipTests'
                        sh 'mvn test -e'
                    }
                }
            }
            post {
                failure {
                    echo 'Unit tests failed. Skipping deployment.'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker image...'
                    docker.build("${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest", ".")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo 'Pushing Docker image to Docker Hub...'
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
                        docker.image("${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest").push()
                    }
                }
            }
        }

        stage('Deploy to VM') {
            steps {
                script {
                    echo 'Deploying application to VM...'
                    sh "docker stop ${APP_NAME} || true"
                    sh "docker rm ${APP_NAME} || true"

                    // Run the new Docker container, mapping HOST_PORT to CONTAINER_PORT
                    // AND connecting it to the 'monitoring_network'
                    sh "docker run -d -p ${HOST_PORT}:${CONTAINER_PORT} --name ${APP_NAME} --network monitoring_network ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest"
                }
            }
            post {
                failure {
                    echo 'Deployment failed!'
                }
                success {
                    echo "Deployment successful! Access your app at http://YOUR_VM_IP_ADDRESS:${HOST_PORT}/Foyer"
                }
            }
        }
    }

    post {
        always {
            cleanWs() // Clean up workspace regardless of build status
        }
        success {
            echo 'Pipeline finished successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}