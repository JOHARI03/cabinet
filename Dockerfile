# Utiliser l'image PHP avec Apache
FROM php:8.4-apache

# Activer le mode non interactif
ENV DEBIAN_FRONTEND=noninteractive

# Définir la variable SRVROOT pour Apache
ENV SRVROOT=/etc/apache2

# Activer les modules Apache nécessaires (HTTP uniquement)
RUN a2enmod rewrite headers

# Assurer les logs d'Apache
RUN mkdir -p /var/log/apache2 && chown -R www-data:www-data /var/log/apache2

# Ajouter la directive ServerName dans la configuration Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Copier ton application locale dans le conteneur Docker
COPY . /var/www/html

# Copier le fichier ports.conf pour configurer le port 80 (HTTP)
COPY docker/ports.conf /etc/apache2/ports.conf

# Copier le fichier httpd.conf personnalisé pour Apache
COPY docker/httpd.conf /etc/apache2/httpd.conf

# Supprimer toute configuration liée à HTTPS (plus besoin du fichier httpd-ssl.conf)
# Aucune copie de certificats SSL, ni activation de sites SSL
# Copier seulement les fichiers nécessaires pour le support HTTP

# Donner les droits appropriés aux fichiers et dossiers (en mode root)
RUN chown -R www-data:www-data /var/www/html /etc/apache2

# Exposer uniquement le port HTTP (80)
EXPOSE 80

# Commande pour démarrer Apache sans support SSL
CMD ["apache2-foreground"]
