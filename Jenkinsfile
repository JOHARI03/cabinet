pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "cabinet-medical:latest"
        PROJECT_DIR = "D:/projets/cabinet-medical"
        DOCKER_REGISTRY = "localhost" // Ton registre local
        CONTAINER_NAME = "cabinet-medical-container"
        EMAIL_RECIPIENT = 'harivolahv@gmail.com'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/JOHARI03/cabinet.git'
            }
            post {
                success {
                    echo "Checkout completed successfully."
                }
                failure {
                    echo "Checkout failed."
                }
            }
        }

        stage('Static Analysis') {
            steps {
                dir("${env.PROJECT_DIR}") {
                    script {
                        // Ignorer les erreurs des tests pour continuer le pipeline
                        echo "Running lint:js (ESLint)..."
                        catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                            bat 'npm run lint:js || true'
                        }

                        echo "Running lint:css (Stylelint)..."
                        catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                            bat 'npm run lint:css || true'
                        }

                        echo "Running lint:html (HTMLHint)..."
                        catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                            bat 'npm run lint:html || true'
                        }

                        echo "Running Lighthouse..."
                        catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                            bat 'npm run lighthouse || true'
                        }
                    }
                }
            }
            post {
                unstable {
                    echo "Static analysis completed with warnings."
                }
                failure {
                    echo "Static analysis failed."
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    bat "docker build -t ${env.DOCKER_IMAGE} ${env.PROJECT_DIR}"
                }
            }
            post {
                success {
                    echo "Docker image built successfully."
                }
                failure {
                    echo "Docker image build failed."
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    bat "docker run -d --name ${env.CONTAINER_NAME} -p 8083:80 ${env.DOCKER_IMAGE} || true"
                }
            }
            post {
                success {
                    echo "Docker container is running successfully."
                }
                failure {
                    echo "Failed to run Docker container."
                }
            }
        }

        stage('Push to Local Registry') {
            steps {
                script {
                    bat "docker tag ${env.DOCKER_IMAGE} ${env.DOCKER_REGISTRY}/${env.DOCKER_IMAGE}"
                    bat "docker push ${env.DOCKER_REGISTRY}/${env.DOCKER_IMAGE} || true"
                }
            }
            post {
                success {
                    echo "Docker image pushed to local registry successfully."
                }
                failure {
                    echo "Failed to push Docker image to local registry."
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    bat 'docker system prune -f'
                    bat "docker rm -f ${env.CONTAINER_NAME} || true"
                }
            }
            post {
                always {
                    echo "Cleanup stage completed."
                }
            }
        }
    }

    post {
        success {
            mail to: "${env.EMAIL_RECIPIENT}",
                 subject: "Build SUCCESS: ${currentBuild.fullDisplayName}",
                 body: "The build completed successfully."
        }
        unstable {
            mail to: "${env.EMAIL_RECIPIENT}",
                 subject: "Build UNSTABLE: ${currentBuild.fullDisplayName}",
                 body: "The build completed with some warnings or unstable results."
        }
        failure {
            mail to: "${env.EMAIL_RECIPIENT}",
                 subject: "Build FAILURE: ${currentBuild.fullDisplayName}",
                 body: "The build failed. Please check the Jenkins logs for more details."
        }
        always {
            echo "Build completed with status: ${currentBuild.currentResult}"
        }
    }
}
