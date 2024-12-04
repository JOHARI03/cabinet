pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "cabinet-medical:latest"
        PROJECT_DIR = "D:/projets/cabinet-medical"
        CONTAINER_NAME = "cabinet-medical-container"
        EMAIL_RECIPIENT = 'harivolahv@gmail.com'
        HOST_PORT = "8084"
        CONTAINER_PORT = "80"
        NPM_DIR = "D:/npm"  // Répertoire npm personnalisé
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/JOHARI03/cabinet.git'
            }
        }

        stage('Install Lighthouse') {
            steps {
                script {
                    echo "Installing Lighthouse globally..."
                    bat "npm config set prefix ${env.NPM_DIR}"  // Configure npm pour utiliser un répertoire personnalisé
                    bat "npm install -g lighthouse"  // Installe Lighthouse globalement
                }
            }
        }

        stage('Static Analysis') {
            steps {
                dir("${env.PROJECT_DIR}") {
                    script {
                        echo "Running lint checks..."
                        bat 'npm run lint:js || exit 0'
                        bat 'npm run lint:css || exit 0'
                        bat 'npm run lint:html || exit 0'
                    }
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image..."
                    bat "docker build -t ${env.DOCKER_IMAGE} ${env.PROJECT_DIR}"
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    echo "Stopping and removing any existing container..."
                    bat "docker stop ${env.CONTAINER_NAME} || exit 0"
                    bat "docker rm ${env.CONTAINER_NAME} || exit 0"

                    echo "Running Docker container..."
                    bat "docker run -d --name ${env.CONTAINER_NAME} -p ${env.HOST_PORT}:${env.CONTAINER_PORT} ${env.DOCKER_IMAGE}"

                    echo "Checking if container is running with correct port mapping..."
                    bat "docker ps | findstr ${env.CONTAINER_NAME}"

                    echo "Testing HTTP connection..."
                    bat "curl http://localhost:${env.HOST_PORT} --max-time 10"
                }
            }
        }

        stage('Lighthouse Audit') {
            steps {
                script {
                    echo "Running Lighthouse audit on the container..."
                    bat "npm run lighthouse -- http://localhost:${env.HOST_PORT} --output html --output-path ./lighthouse-report.html"
                    archiveArtifacts artifacts: 'lighthouse-report.html', allowEmptyArchive: true
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    echo "Cleaning up Docker resources..."
                    bat "docker system prune -f"
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline terminé avec succès.'
            mail to: "$EMAIL_RECIPIENT",
                 subject: "SUCCÈS : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                 body: """<h2 style='color: green;'>Le pipeline ${env.JOB_NAME} (Build #${env.BUILD_NUMBER}) a terminé avec succès.</h2>
                          Détails : <a href="${env.BUILD_URL}">Voir le build ici</a>""",
                 mimeType: 'text/html'
        }
        failure {
            echo 'Échec du pipeline.'
            mail to: "$EMAIL_RECIPIENT",
                 subject: "ÉCHEC : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                 body: """<h2 style='color: red;'>Le pipeline ${env.JOB_NAME} (Build #${env.BUILD_NUMBER}) a échoué.</h2>
                          Consultez les logs : <a href="${env.BUILD_URL}">Voir les logs ici</a>""",
                 mimeType: 'text/html'
        }
        aborted {
            echo 'Pipeline a été interrompu !'
            mail to: "$EMAIL_RECIPIENT",
                 subject: "ABORTÉ : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                 body: """<h2 style='color: orange;'>Le pipeline ${env.JOB_NAME} (Build #${env.BUILD_NUMBER}) a été interrompu (ABORTED).</h2>
                          Consultez les logs : <a href="${env.BUILD_URL}">Voir les logs ici</a>""",
                 mimeType: 'text/html'
        }
        always {
            echo 'Nettoyage de l’espace de travail et des ressources Docker...'
            cleanWs()
            bat "docker container prune -f"
            bat "docker image prune -f"
        }
    }
}
