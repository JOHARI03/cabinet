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
                    bat "docker build -t ${env.DOCKER_IMAGE} ${env.PROJECT_DIR}"
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    // Supprimer tout conteneur existant avec le même nom
                    bat "docker stop ${env.CONTAINER_NAME} || exit 0"
                    bat "docker rm ${env.CONTAINER_NAME} || exit 0"

                    // Lancer un nouveau conteneur avec le nom et le mappage de port spécifié
                    bat "docker run -d --name ${env.CONTAINER_NAME} -p 8084:80 ${env.DOCKER_IMAGE}"

                    // Vérifier si le conteneur est actif avec le bon mappage de port
                    bat "docker ps | findstr ${env.CONTAINER_NAME}"
                }
            }
            post {
                success {
                    echo "Docker container is running successfully on port 8084."
                }
                failure {
                    echo "Failed to run Docker container. Inspect logs below:"
                    bat "docker logs ${env.CONTAINER_NAME} || exit 0"
                    currentBuild.result = 'ABORTED'  // Si l'étape échoue, on marque le pipeline comme 'ABORTED'
                    error "Docker container failed to start."
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    bat "docker system prune -f"
                    bat "docker rm -f ${env.CONTAINER_NAME} || exit 0"
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
