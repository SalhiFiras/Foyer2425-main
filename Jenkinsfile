pipeline {
    agent any // Or 'agent { docker { image 'maven:3.8.5-openjdk-17' } }' for a more isolated build environment

    environment {
        // Define your Docker Hub username and image name
        DOCKER_HUB_USERNAME = 'salhifiras'
        IMAGE_NAME = 'foyer2425-main'
        APP_NAME = 'my-spring-boot-app'
        HOST_PORT = 8081 // New port for the Spring Boot application on the VM host
        CONTAINER_PORT = 8080 // Internal port of the Spring Boot application
    }

    stages {
        stage('Checkout Code') {
            steps {
                script {
                    echo 'Checking out SCM...'
                    // Ensure your SCM (e.g., Git) configuration is set up in Jenkins job settings
                    checkout scm
                }
            }
        }

        stage('Run Unit Tests') {
            steps {
                script {
                    echo 'Running Maven Unit Tests...'
                    // Use a Maven Docker image for consistent builds
                    docker.image('maven:3.8.5-openjdk-17').inside {
                        sh 'mvn clean install -DskipTests' // Build without running tests initially
                        sh 'mvn test -e' // Run tests with error details
                    }
                }
            }
            post {
                failure {
                    echo 'Unit tests failed. Skipping deployment.'
                    // Optional: You can add more actions here, like sending notifications
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo 'Building Docker image...'
                    // Build the Docker image using the Dockerfile in the project root
                    docker.build("${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest", ".")
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    echo 'Pushing Docker image to Docker Hub...'
                    // Authenticate and push the image to Docker Hub
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') { // 'docker-hub-credentials' is the ID of your Jenkins credential
                        docker.image("${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest").push()
                    }
                }
            }
        }

        stage('Deploy to VM') {
            steps {
                script {
                    echo 'Deploying application to VM...'
                    // Stop and remove the old container, ignore errors if it doesn't exist
                    sh "docker stop ${APP_NAME} || true"
                    sh "docker rm ${APP_NAME} || true"

                    // Run the new Docker container, mapping HOST_PORT to CONTAINER_PORT
                    sh "docker run -d -p ${HOST_PORT}:${CONTAINER_PORT} --name ${APP_NAME} ${DOCKER_HUB_USERNAME}/${IMAGE_NAME}:latest"
                }
            }
            post {
                failure {
                    echo 'Deployment failed!'
                    // Optional: Clean up failed deployment attempts or notify
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