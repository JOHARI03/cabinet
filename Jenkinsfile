pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "cabinet-medical:latest"  // Nom local de l'image
        PROJECT_DIR = "D:/projets/cabinet-medical"
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
                            bat 'npm run lint:js || exit 0'
                        }

                        echo "Running lint:css (Stylelint)..."
                        catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                            bat 'npm run lint:css || exit 0'
                        }

                        echo "Running lint:html (HTMLHint)..."
                        catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                            bat 'npm run lint:html || exit 0'
                        }

                        echo "Running Lighthouse..."
                        catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                            bat 'npm run lighthouse || exit 0'
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
                    bat "docker run -d --name ${env.CONTAINER_NAME} -p 8083:80 ${env.DOCKER_IMAGE}"
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

        stage('Cleanup') {
            steps {
                script {
                    bat 'docker system prune -f'
                    bat "docker rm -f ${env.CONTAINER_NAME} || exit 0"
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
            emailext(
                subject: "Build SUCCESS: ${currentBuild.fullDisplayName}",
                body: "The build completed successfully.",
                to: "${env.EMAIL_RECIPIENT}"
            )
        }
        unstable {
            emailext(
                subject: "Build UNSTABLE: ${currentBuild.fullDisplayName}",
                body: "The build completed with some warnings or unstable results.",
                to: "${env.EMAIL_RECIPIENT}"
            )
        }
        failure {
            emailext(
                subject: "Build FAILURE: ${currentBuild.fullDisplayName}",
                body: "The build failed. Please check the Jenkins logs for more details.",
                to: "${env.EMAIL_RECIPIENT}"
            )
        }
        always {
            echo "Build completed with status: ${currentBuild.currentResult}"
        }
    }
}
