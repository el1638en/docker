# Choisir l'image sur laquelle on se base pour créer cette image.
FROM openjdk:8

# Auteur de l'image
LABEL description="apps-api-1.0.0 on Tomcat 9" \
      maintainer="Eric LEGBA - eric.legba@gmail.com"

# Définir les variables d'environnement
ENV CATALINA_HOME /usr/local/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
ENV TOMCAT_MAJOR 9
ENV TOMCAT_VERSION 9.0.27
ENV TOMCAT_TAR_GZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN mkdir -p $CATALINA_HOME
WORKDIR $CATALINA_HOME

RUN set -x \
    && curl -fSL $TOMCAT_TAR_GZ_URL -o tomcat.tar.gz \
    && tar -xvf tomcat.tar.gz --strip-components=1 \
    && rm bin/*.bat \
    && rm tomcat.tar.gz*

# Ajouter le fichier war de l'application
ADD apps-api-1.0.0.war $CATALINA_HOME/webapps/

EXPOSE 8080

# Actuator health check
HEALTHCHECK --interval=15m --timeout=10s --retries=3 --start-period=1m CMD curl --fail http://localhost:8080/apps-api-1.0.0/actuator/health || exit 1

# Commande à exécuter au démarrage du serveur.
CMD ["catalina.sh", "run"]
