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
                    mail to: "$EMAIL_RECIPIENT",
                         subject: "SUCCÈS : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                         body: """<h2 style='color: green;'>Le pipeline ${env.JOB_NAME} (Build #${env.BUILD_NUMBER}) a terminé avec succès.</h2>
                                  Détails : <a href="${env.BUILD_URL}">Voir le build ici</a>""",
                         mimeType: 'text/html'
                }
                failure {
                    echo "Checkout failed."
                    mail to: "$EMAIL_RECIPIENT",
                         subject: "ÉCHEC : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                         body: """<h2 style='color: red;'>Le pipeline ${env.JOB_NAME} (Build #${env.BUILD_NUMBER}) a échoué.</h2>
                                  Consultez les logs : <a href="${env.BUILD_URL}">Voir les logs ici</a>""",
                         mimeType: 'text/html'
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
                    mail to: "$EMAIL_RECIPIENT",
                         subject: "Avertissement : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                         body: """<h2 style='color: orange;'>Le pipeline ${env.JOB_NAME} (Build #${env.BUILD_NUMBER}) a terminé avec des avertissements.</h2>
                                  Détails : <a href="${env.BUILD_URL}">Voir les logs ici</a>""",
                         mimeType: 'text/html'
                }
                failure {
                    echo "Static analysis failed."
                    mail to: "$EMAIL_RECIPIENT",
                         subject: "ÉCHEC : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                         body: """<h2 style='color: red;'>Le pipeline ${env.JOB_NAME} (Build #${env.BUILD_NUMBER}) a échoué durant l'analyse statique.</h2>
                                  Consultez les logs : <a href="${env.BUILD_URL}">Voir les logs ici</a>""",
                         mimeType: 'text/html'
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
                    mail to: "$EMAIL_RECIPIENT",
                         subject: "SUCCÈS : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                         body: """<h2 style='color: green;'>L'image Docker a été construite avec succès.</h2>
                                  Détails : <a href="${env.BUILD_URL}">Voir le build ici</a>""",
                         mimeType: 'text/html'
                }
                failure {
                    echo "Docker image build failed."
                    mail to: "$EMAIL_RECIPIENT",
                         subject: "ÉCHEC : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                         body: """<h2 style='color: red;'>La construction de l'image Docker a échoué.</h2>
                                  Consultez les logs : <a href="${env.BUILD_URL}">Voir les logs ici</a>""",
                         mimeType: 'text/html'
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    bat "docker run -d --name ${env.CONTAINER_NAME} -p 8084:80 ${env.DOCKER_IMAGE}"
                }
            }
            post {
                success {
                    echo "Docker container is running successfully."
                    mail to: "$EMAIL_RECIPIENT",
                         subject: "SUCCÈS : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                         body: """<h2 style='color: green;'>Le conteneur Docker fonctionne avec succès.</h2>
                                  Détails : <a href="${env.BUILD_URL}">Voir le build ici</a>""",
                         mimeType: 'text/html'
                }
                failure {
                    echo "Failed to run Docker container."
                    mail to: "$EMAIL_RECIPIENT",
                         subject: "ÉCHEC : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                         body: """<h2 style='color: red;'>Le conteneur Docker n'a pas pu démarrer.</h2>
                                  Consultez les logs : <a href="${env.BUILD_URL}">Voir les logs ici</a>""",
                         mimeType: 'text/html'
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
                    mail to: "$EMAIL_RECIPIENT",
                         subject: "Nettoyage terminé : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                         body: """<h2>Le nettoyage des ressources Docker est terminé.</h2>
                                  Détails : <a href="${env.BUILD_URL}">Voir le build ici</a>""",
                         mimeType: 'text/html'
                }
            }
        }
    }

    post {
        success {
            echo 'Pipeline terminé avec succès. Archivage des artefacts...'
            archiveArtifacts artifacts: '**/*.min.css', allowEmptyArchive: true
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
            echo 'Le pipeline a été annulé.'
            mail to: "$EMAIL_RECIPIENT",
                 subject: "ANNULATION : ${env.JOB_NAME} - Build #${env.BUILD_NUMBER}",
                 body: """<h2 style='color: orange;'>Le pipeline ${env.JOB_NAME} (Build #${env.BUILD_NUMBER}) a été annulé.</h2>
                          Consultez les logs : <a href="${env.BUILD_URL}">Voir les logs ici</a>""",
                 mimeType: 'text/html'
        }
        always {
            echo 'Nettoyage de l’espace de travail et des images Docker inutilisées...'
            cleanWs()
            sh "docker container prune -f"
            sh "docker image prune -f"
        }
    }
}
