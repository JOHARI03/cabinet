# Utiliser l'image PHP avec Apache
FROM php:8.4-apache

# Activer le mode non interactif pour éviter les questions lors de l'installation des paquets
ENV DEBIAN_FRONTEND=noninteractive

# Activer les modules Apache nécessaires (HTTP uniquement)
RUN a2enmod rewrite headers

# Créer et ajuster les logs Apache
RUN mkdir -p /var/log/apache2 && chown -R www-data:www-data /var/log/apache2

# Ajouter la directive ServerName dans la configuration Apache pour éviter les erreurs de démarrage
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copier le fichier httpd.conf depuis le dossier du projet local dans le conteneur
COPY D:/projets/cabinet-medical/httpd.conf /etc/apache2/httpd.conf

# Copier l'application locale dans le conteneur Docker
COPY . /var/www/html

# Ajuster les permissions sur les fichiers et dossiers dans le conteneur
RUN chown -R www-data:www-data /var/www/html /etc/apache2 /var/log/apache2

# Exposer uniquement le port HTTP (80)
EXPOSE 80

# Démarrer Apache en avant-plan sans support SSL (nous utilisons uniquement HTTP)
CMD ["apache2-foreground"]
