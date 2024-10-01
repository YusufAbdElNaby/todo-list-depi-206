pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'todo-list-app'
        DOCKER_TAG = 'latest'
        DOCKER_HUB_CREDENTIALS = 'docker-hub-credentials-id'  // Jenkins credentials ID for Docker Hub
        GITHUB_REPO = 'https://github.com/YusufAbdElNaby/todo-list-depi-206.git'  //  GitHub repo
    }
    tools {
        jdk 'jdk17'
        maven 'maven3' // The name you specified in Global Tool Configuration
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
        stage('File System Scan') {
            steps {
                sh "trivy fs --format table -o trivy-fs-report.html ."
            }
        }
        stage('SonarQube Analsyis') {
            steps {
                withSonarQubeEnv('sonar') {
                  withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh ''' mvn sonar:sonar \
                             -Dsonar.projectKey=todo-list-depi \
                             -Dsonar.host.url=http://ec2-15-236-175-182.eu-west-3.compute.amazonaws.com:9000 \
                             -Dsonar.login=$SONAR_TOKEN
                    '''
                  }
                }
            }
        }
//         stage('Quality Gate') {
//             steps {
//                 script {
//                     waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token'
//                 }
//             }
//         }
        stage('Quality Gate') {
                    steps {
                        timeout(time: 30, unit: 'SECONDS') {
                            script {
                                def qualityGate = waitForQualityGate()
                                if (qualityGate.status != 'OK') {
                                    error "Pipeline aborted due to quality gate failure: ${qualityGate.status}"
                                }
                            }
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
        stage('Docker Image Scan') {
            steps {
                sh "trivy image --format table -o trivy-image-report.html ${DOCKER_IMAGE}:${DOCKER_TAG} "
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
            script {
                def jobName = env.JOB_NAME
                def buildNumber = env.BUILD_NUMBER
                def pipelineStatus = currentBuild.result ?: 'UNKNOWN'
                def bannerColor = pipelineStatus.toUpperCase() == 'SUCCESS' ? 'green' : 'red'
                def email_recipients = 'fahmy1.diab@gmail.com,yusuf.abdelnabi@gmail.com,yousefosama3@gmail.com,baraa.almodrek@hotmail.com,tahagamil@gmail.com'
                def body = """
                            <html>
                                <body>
                                  <div style="border: 4px solid ${bannerColor}; padding:10px;">
                                    <h2>${jobName} - Build ${buildNumber}</h2>
                                        <div style="background-color:${bannerColor}; padding:10px;">
                                            <h3 style="color: white;">Pipeline Status: ${pipelineStatus.toUpperCase()}</h3>
                                        </div>
                                    <p>Check the <a href="${BUILD_URL}">console output</a>.</p>
                                  </div>
                                </body>
                            </html>
                            """
                emailext(
                    subject: "${jobName} - Build ${buildNumber} - ${pipelineStatus.toUpperCase()}",
                    body: body,
                    to: email_recipients, from : 'fahmy1.diab@gmail.com', replyTo: 'fahmy1.diab@gmail.com',
                    mimType: 'text/html', attachmentsPattern: 'trivy-image-report.html'
                )
            }
        }
    }
}
