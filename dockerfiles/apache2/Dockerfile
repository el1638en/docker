# Choisir l'image sur laquelle on se base pour créer cette image.
FROM debian:latest

# Auteur de l'image
LABEL description="Apache2 based on Debian" \
      maintainer="Eric LEGBA - eric.legba@gmail.com"

# Définition des variables d'environnement
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data

# Définition des variables pour la construction de l'image
ARG APACHE_STATUS_USERNAME=root
ARG APACHE_STATUS_PASSWORD=Mmdp-3325
ARG HTPASSWD_FILE=/var/www/status/.htpasswd

# Installer Apache2
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install apache2

# Désactiver la configuration de securité par defaut, suppression du repertoire /var/www/html
RUN a2disconf security \
    && rm -rf /var/www/html

# Personnaliser la configuration d'Apache2
COPY apache2.conf /etc/apache2

# Configuration du module Apache2 status
RUN mkdir /var/www/status \
    && /usr/bin/htpasswd -csb $HTPASSWD_FILE $APACHE_STATUS_USERNAME $APACHE_STATUS_PASSWORD

COPY status.conf /etc/apache2/mods-available
RUN a2enmod status

EXPOSE 80 443

CMD ["apache2ctl","-D","FOREGROUND"]
