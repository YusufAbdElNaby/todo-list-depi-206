pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'todo-list-app'
        DOCKER_TAG = 'latest'
        DOCKER_HUB_CREDENTIALS = 'docker-hub-credentials-id'  // Jenkins credentials ID for Docker Hub
        GITHUB_REPO = 'https://github.com/YusufAbdElNaby/todo-list-depi-206.git'  //  GitHub repo
        EMAIL_RECIPIENTS = 'fahmy1.diab@gmail.com'
    }
    tools {
        maven 'Maven 3.8.6' // The name you specified in Global Tool Configuration
    }
    stages {
        stage('Checkout') {
            steps {
                // Clone the GitHub repository
                git branch: 'main', url: "${GITHUB_REPO}"
            }
        }
        stage('Build and Test') {
            steps {
               sh 'ls -ltr'
              // build the project and create a JAR file
              sh 'mvn clean package'
            }
        }
        stage('Static Code Analysis') {
           environment {
             SONAR_URL = "http://172.17.0.3:9000"
           }
           steps {
             withCredentials([string(credentialsId: 'sonarqube-cred', variable: 'SONAR_AUTH_TOKEN')]) {
                sh 'mvn sonar:sonar -Dsonar.login=$SONAR_AUTH_TOKEN -Dsonar.host.url=${SONAR_URL}'
             }
           }
        }
        stage('Build Docker Image') {
            steps {
                // Build the Docker image using the Dockerfile
                script {
                    sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                }
            }
        }

        stage('Docker Login') {
            steps {
                // Log in to Docker Hub (optional, if you're pushing the image)
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDENTIALS}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                        sh "echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin"
                    }
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                // Push the Docker image to Docker Hub
                script {
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_CREDENTIALS}", passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                    sh "echo image name is ${DOCKER_USERNAME}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_USERNAME}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                    sh "docker push ${DOCKER_USERNAME}/${DOCKER_IMAGE}:${DOCKER_TAG}"
                    }
                }
            }
        }

        stage('Cleanup') {
            steps {
                // Clean up Docker images to save space on the Jenkins server
                sh "docker rmi ${DOCKER_IMAGE}:${DOCKER_TAG}"
            }
        }
    }

    post {
        always {
            // Clean workspace after build
            cleanWs()
        }

        success {
                    mail bcc: '', body: "Build completed successfully. View it here: ${env.BUILD_URL}",
                         cc: '', from: '', replyTo: '', subject: "Build Success: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                         to: "${EMAIL_RECIPIENTS}"
                    echo 'Build completed successfully!'
        }

        failure {
                    mail bcc: '', body: "Build failed. View it here: ${env.BUILD_URL}",
                         cc: '', from: '', replyTo: '', subject: "Build Failed: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                         to: "${EMAIL_RECIPIENTS}"
                    echo 'Build failed!'
        }
    }
}
