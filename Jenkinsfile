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
                    script {
                        echo "Code successfully checked out."
                        currentBuild.result = 'SUCCESS'
                    }
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Checkout Success",
                        body: "<p>Checkout stage passed successfully: <font color='green'>Success</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
                }
                failure {
                    script {
                        currentBuild.result = 'FAILURE'
                    }
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Checkout Failed",
                        body: "<p>Checkout stage failed: <font color='red'>Failure</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
                }
                aborted {
                    script {
                        currentBuild.result = 'ABORTED'
                    }
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Checkout Aborted",
                        body: "<p>Checkout stage was aborted: <font color='orange'>Aborted</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
                }
            }
        }

        stage('Static Analysis') {
            steps {
                dir("${env.PROJECT_DIR}") {
                    script {
                        echo "Running lint:js (ESLint)..."
                        bat 'npm run lint:js'

                        echo "Running lint:css (Stylelint)..."
                        bat 'npm run lint:css'

                        echo "Running lint:html (HTMLHint)..."
                        bat 'npm run lint:html'

                        echo "Running Lighthouse..."
                        bat 'npm run lighthouse'
                    }
                }
            }
            post {
                success {
                    script {
                        echo "Static analysis passed successfully."
                        currentBuild.result = 'SUCCESS'
                    }
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Static Analysis Success",
                        body: "<p>Static analysis passed successfully: <font color='green'>Success</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
                }
                failure {
                    script {
                        currentBuild.result = 'FAILURE'
                    }
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Static Analysis Failed",
                        body: "<p>Static analysis failed: <font color='red'>Failure</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
                }
                aborted {
                    script {
                        currentBuild.result = 'ABORTED'
                    }
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Static Analysis Aborted",
                        body: "<p>Static analysis was aborted: <font color='orange'>Aborted</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
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
                    script {
                        echo "Docker image built successfully."
                        currentBuild.result = 'SUCCESS'
                    }
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Docker Image Built",
                        body: "<p>Docker image built successfully: <font color='green'>Success</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
                }
                failure {
                    script {
                        currentBuild.result = 'FAILURE'
                    }
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Docker Image Build Failed",
                        body: "<p>Docker image build failed: <font color='red'>Failure</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
                }
                aborted {
                    script {
                        currentBuild.result = 'ABORTED'
                    }
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Docker Image Build Aborted",
                        body: "<p>Docker image build was aborted: <font color='orange'>Aborted</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
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
                    script {
                        echo "Docker container is running on port 8083 successfully."
                        currentBuild.result = 'SUCCESS'
                    }
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Docker Container Running",
                        body: "<p>Docker container is running on port 8083 successfully: <font color='green'>Success</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
                }
                failure {
                    script {
                        currentBuild.result = 'FAILURE'
                    }
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Docker Container Failed",
                        body: "<p>Failed to run Docker container: <font color='red'>Failure</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
                }
                aborted {
                    script {
                        currentBuild.result = 'ABORTED'
                    }
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Docker Container Aborted",
                        body: "<p>Docker container run was aborted: <font color='orange'>Aborted</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
                }
            }
        }

        stage('Push to Local Registry') {
            steps {
                script {
                    bat "docker tag ${env.DOCKER_IMAGE} ${env.DOCKER_REGISTRY}/${env.DOCKER_IMAGE}"
                    bat "docker push ${env.DOCKER_REGISTRY}/${env.DOCKER_IMAGE}"
                }
            }
            post {
                success {
                    script {
                        echo "Docker image pushed to local registry successfully."
                        currentBuild.result = 'SUCCESS'
                    }
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Docker Image Pushed",
                        body: "<p>Docker image pushed to local registry successfully: <font color='green'>Success</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
                }
                failure {
                    script {
                        currentBuild.result = 'FAILURE'
                    }
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Docker Image Push Failed",
                        body: "<p>Failed to push Docker image to local registry: <font color='red'>Failure</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
                }
                aborted {
                    script {
                        currentBuild.result = 'ABORTED'
                    }
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Docker Image Push Aborted",
                        body: "<p>Docker image push was aborted: <font color='orange'>Aborted</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    bat 'docker system prune -f'
                    bat "docker rm -f ${env.CONTAINER_NAME}"  // Supprimer le conteneur après usage
                }
            }
            post {
                always {
                    emailext(
                        subject: "Build ${currentBuild.fullDisplayName} - Cleanup Done",
                        body: "<p>Cleanup stage completed: <font color='blue'>Always</font></p>",
                        to: "${env.EMAIL_RECIPIENT}"
                    )
                }
            }
        }
    }

    post {
        always {
            emailext(
                subject: "Final Build Status: ${currentBuild.fullDisplayName} - ${currentBuild.currentResult}",
                body: "<p>Build ${currentBuild.fullDisplayName} finished with status: <b><font color='${getColorForStatus(currentBuild.currentResult)}'>${currentBuild.currentResult}</font></b>.</p>",
                to: "${env.EMAIL_RECIPIENT}"
            )
        }
    }
}
