## Docker

Un Conteneur Linux est un processus ou un ensemble de processus isolés du reste du système. Un conteneur qui accueille une application contient tous les fichiers, les bibliothèques et les dépendances nécessaires au fonctionnement de l'application de façon autonome. Il est portable et fonctionne de la même manière sur un environnement de développement, de test ou de production. Sous Linux, la techologie de virtualisation [LXC](https://linuxcontainers.org/fr/) permet de fabriquer des conteneurs.

On voit que Docker n'a pas inventé les conteneurs.
Par contre, Docker est un outil qui permet de créer plus facilement des conteneurs afin d'isoler des applications dans des "prisons" pour ne pas gêner d'autres applications. L'intérêt de Docker réside dans l'utilisation des outils qu'il propose pour fabriquer des conteneurs de manière plus simplifiée.

1. Installation

  Pour installer Docker, se référer à la [documentation officielle en ligne](https://docs.docker.com/install/). Dans ce document, nous allons nous concentrer sur Dockerfile.

2. [Dockerfile](https://docs.docker.com/engine/reference/builder/)

  Docker utilise des images officielles pour créer des conteneurs. Savoir utiliser des images, c'est bien. Savoir créer des images personnalisées, c'est encore mieux.

  Une méthode pour créer une image Docker est d'utiliser un fichier Dockerfile. Le Dockerfile contient toutes les instructions (métadonnées, commande shell, etc...) pour créer une image. Il se base sur une image existante pour créer une nouvelle image.

  Voici un aperçu des commandes Docker :

  ```shell
  FROM # Pour choisir l'image de base toujours en premier
  RUN # Permet d'exécuter une commande
  CMD # Commande exécutée au démarrage du conteneur par défaut
  EXPOSE # Ouvrir un port
  ENV # Permet d'éditer des variables d'environnement
  ARG # Un peu comme ENV, mais seulement le temps de la construction de l'image
  COPY # Permet de copier un fichier ou répertoire de l'hôte vers l'image
  ADD # Permet de copier un fichier de l'hôte ou depuis une URL vers l'image, permet également de décompresser un
  ENTRYPOINT # Commande exécutée au démarrage du conteneur
  VOLUME # Crée une partition spécifique
  WORKDIR # Permet de choisir le répertoire de travail
  USER # Choisit l'utilisateur qui lance la commande du ENTRYPOINT ou du CMD
  HEALTHCHECK # Permet d'ajouter une commande pour vérifier l'état de fonctionnement du conteneur
  STOPSIGNAL # permet de choisir le signal qui sera envoyé au conteneur lorsque vous ferez un docker container stop
  ```

  La liste des instructions disponibles dans un Dockerfile est accessible dans la [documentation officielle](https://docs.docker.com/engine/reference/builder/).

  Voici un exemple de Dockerfile qui crée l'image d'un serveur Tomcat avec une application war embarquée dans le webapps.

  ```shell
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
  ```

  Quelques commentaires :
    - `FROM openjdk:8` : on se base sur l'image de Java 8
    - `ENV CATALINA_HOME /usr/local/tomcat` : On définit des variables d'environnement telles que le répertoire d'installation d'Apache Tomcat, la version d'Apache Tomcat à installer, etc...
    - l'archive du serveur d'Apache Tomcat est téléchargé et dézippé. Etant sur un environnement Linux, on supprime les fichiers ` *.bat`.
    - `ADD apps-api-1.0.0.war $CATALINA_HOME/webapps/` : le fichier war est ajouté dans le répertoire `webapps` de Tomcat.
    - `EXPOSE 8080` : On expose le port `8080`
    -  `CMD ["catalina.sh", "run"]` : enfin, nous ajoutons la commande à lancer au démarrage du container (l'exécution du script `catalina.sh`).

  Pour construire l'image, utiliser la commande `docker image build -t [tagName:version] .`. Pour en savoir plus sur la commande, consulter l'aide `docker image build --help`

  Dans notre cas, nous allons créer l'image `apps-api:1.0.0` :

  ```shell
  docker image build -t apps-api:1.0.0 .
  ```

  Voici la sortie console :

  ```shell
  legeric@pl-debian:~/dev/devops/workspace/dockerfiles/tomcat9$ docker image build -t apps-api:1.0.0 .                              
  Sending build context to Docker daemon  21.64MB
  Step 1/14 : FROM openjdk:8
   ---> 57c2c2d2643d
  Step 2/14 : LABEL description="apps-api-1.0.0 on Tomcat 9"       maintainer="Eric LEGBA - eric.legba@gmail.com"
   ---> Using cache
   ---> 3e89a8ebe677
  Step 3/14 : ENV CATALINA_HOME /usr/local/tomcat
   ---> Using cache
   ---> 0442cd0dfe48
  Step 4/14 : ENV PATH $CATALINA_HOME/bin:$PATH
   ---> Using cache
   ---> 90df51df6753
  Step 5/14 : ENV TOMCAT_MAJOR 9
   ---> Running in 86a4e6a67e3b
  Removing intermediate container 86a4e6a67e3b
   ---> 5cbc6180c13e
  Step 6/14 : ENV TOMCAT_VERSION 9.0.27
   ---> Running in 5007f9ed7fe6
  Removing intermediate container 5007f9ed7fe6
   ---> 6325ac7ca5cb
  Step 7/14 : ENV TOMCAT_TAR_GZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz
   ---> Running in d0889611b8f1
  Removing intermediate container d0889611b8f1
   ---> 49e0547f0f7e
  Step 8/14 : RUN mkdir -p $CATALINA_HOME
   ---> Running in b501e158b02c
  Removing intermediate container b501e158b02c
   ---> 07a09bb50458
  Step 9/14 : WORKDIR $CATALINA_HOME
  Removing intermediate container 538654cdd239
   ---> f72173c7b5be
  Step 10/14 : RUN set -x     && curl -fSL $TOMCAT_TAR_GZ_URL -o tomcat.tar.gz     && tar -xvf tomcat.tar.gz --strip-components=1     && rm bin/*.bat     && rm tomcat.tar.gz*
   ---> Running in 6adc7865b9b1
  + curl -fSL https://www.apache.org/dist/tomcat/tomcat-9/v9.0.27/bin/apache-tomcat-9.0.27.tar.gz -o tomcat.tar.gz
    % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current                                                                                                                 
                                   Dload  Upload   Total   Spent    Left  Speed                                                                                                                   
  100 10.4M  100 10.4M    0     0  2018k      0  0:00:05  0:00:05 --:--:-- 2390k                                                                                                                  
  + tar -xvf tomcat.tar.gz --strip-components=1                                                                                                                         
  + rm bin/catalina.bat bin/ciphers.bat bin/configtest.bat bin/digest.bat bin/makebase.bat bin/setclasspath.bat bin/shutdown.bat bin/startup.bat bin/tool-wrapper.bat bin/version.bat
  + rm tomcat.tar.gz
  Removing intermediate container 6adc7865b9b1
   ---> 1517608f7cc6
  Step 11/14 : ADD apps-api-1.0.0.war $CATALINA_HOME/webapps/
   ---> 6586021d4933
  Step 12/14 : EXPOSE 8080
   ---> Running in ebf0cd530d23
  Removing intermediate container ebf0cd530d23
   ---> b0fc817dfd91
  Step 13/14 : HEALTHCHECK --interval=15m --timeout=10s --retries=3 --start-period=1m CMD curl --fail http://localhost:8080/apps-api-1.0.0/actuator/health || exit 1
   ---> Running in 5c387b2b88bc
  Removing intermediate container 5c387b2b88bc
   ---> 9d9d4e4e8cd8
  Step 14/14 : CMD ["catalina.sh", "run"]
   ---> Running in d8b924546789
  Removing intermediate container d8b924546789
   ---> 9999d08e38ea
  Successfully built 9999d08e38ea
  Successfully tagged apps-api:1.0.0
  ```

  On peut vérifier la présence de l'image dans le registry local :

  ```shell
  legeric@pl-debian:~$ docker image ls -a
  REPOSITORY               TAG                 IMAGE ID            CREATED             SIZE
  apps-api                 1.0.0               9999d08e38ea        6 minutes ago       525MB
  ```

  Ensuite nous pouvons tester l'image en créant un conteneur à partir de celle-ci :

  ```shell
  legeric@pl-debian:~$ docker container run -it -p 8080:8080 --name apps-api apps-api:1.0.0
  ```

  Pour accéder au logs du container `apps-api` :

  ```shell
  legeric@pl-debian:~$ docker logs apps-api
  Using CATALINA_BASE:   /usr/local/tomcat
  Using CATALINA_HOME:   /usr/local/tomcat
  Using CATALINA_TMPDIR: /usr/local/tomcat/temp
  Using JRE_HOME:        /usr/local/openjdk-8
  Using CLASSPATH:       /usr/local/tomcat/bin/bootstrap.jar:/usr/local/tomcat/bin/tomcat-juli.jar
  10-Nov-2019 12:40:48.538 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Server version name:   Apache Tomcat/9.0.27
  10-Nov-2019 12:40:48.540 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Server built:          Oct 7 2019 09:57:22 UTC
  10-Nov-2019 12:40:48.540 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Server version number: 9.0.27.0
  10-Nov-2019 12:40:48.540 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log OS Name:               Linux
  10-Nov-2019 12:40:48.540 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log OS Version:            4.9.0-8-amd64
  10-Nov-2019 12:40:48.541 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Architecture:          amd64
  10-Nov-2019 12:40:48.541 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Java Home:             /usr/local/openjdk-8/jre
  10-Nov-2019 12:40:48.543 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Command line argument: -Djava.util.logging.config.file=/usr/local/tomcat/conf/logging.properties
  10-Nov-2019 12:40:48.543 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Command line argument: -Djava.util.logging.manager=org.apache.juli.ClassLoaderLogManager
  10-Nov-2019 12:40:48.544 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Command line argument: -Djdk.tls.ephemeralDHKeySize=2048
  10-Nov-2019 12:40:48.544 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Command line argument: -Djava.protocol.handler.pkgs=org.apache.catalina.webresources
  10-Nov-2019 12:40:48.544 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Command line argument: -Dorg.apache.catalina.security.SecurityListener.UMASK=0027
  10-Nov-2019 12:40:48.544 INFO [main] org.apache.catalina.startup.VersionLoggerListener.log Command line argument: -Djava.io.tmpdir=/usr/local/tomcat/temp
  10-Nov-2019 12:40:48.992 INFO [main] org.apache.catalina.startup.HostConfig.deployWAR Deploying web application archive [/usr/local/tomcat/webapps/apps-api-1.0.0.war]

    .   ____          _            __ _ _
   /\\ / ___'_ __ _ _(_)_ __  __ _ \ \ \ \
  ( ( )\___ | '_ | '_| | '_ \/ _` | \ \ \ \
   \\/  ___)| |_)| | | | | || (_| |  ) ) ) )
    '  |____| .__|_| |_|_| |_\__, | / / / /
   =========|_|==============|___/=/_/_/_/
   :: Spring Boot ::        (v2.1.2.RELEASE)

  2019-11-10 12:40:51 - Starting AppsApiApplication v1.0.0 on 86d198868125 with PID 1 (/usr/local/tomcat/webapps/apps-api-1.0.0/WEB-INF/classes started by root in /usr/local/tomcat)
  2019-11-10 12:40:51 - No active profile set, falling back to default profiles: default
  2019-11-10 12:40:53 - Bean 'org.springframework.ws.config.annotation.DelegatingWsConfiguration' of type [org.springframework.ws.config.annotation.DelegatingWsConfiguration$$EnhancerBySpringCGLIB$$11d85f5a] is not eligible for getting processed by all BeanPostProcessors (for example: not eligible for auto-proxying)
  2019-11-10 12:40:53 - Supporting [WS-Addressing August 2004, WS-Addressing 1.0]
  2019-11-10 12:40:53 - Root WebApplicationContext: initialization completed in 1820 ms
  2019-11-10 12:40:54 - Initializing ExecutorService 'applicationTaskExecutor'
  2019-11-10 12:40:54 - Exposing 2 endpoint(s) beneath base path '/actuator'
  2019-11-10 12:40:54 - Started AppsApiApplication in 4.158 seconds (JVM running for 6.716)
  10-Nov-2019 12:40:55.298 INFO [main] org.apache.catalina.startup.Catalina.start Server startup in [6,389] milliseconds
  ```

  __**Remarque**__

  Une instruction du Dockerfile est construite sur la base des instructions qui la précèdent. Une instruction est un layer (une couche) construite à partir des instructions (layers) précédentes. Multiplier les layers dans une image peut diminuer les performances de celles-ci. Par exemple, si nous avons besoin d'une commande dans un layer et que celle-ci avait été créée 10 layers plus haut, le conteneur recherchera la commande layer après layer jusqu'à retrouver la commande. Si le nombre de layers est considérable, cela peut impacter les performances.
  Pour éviter cela, il est conseillé de regrouper plusieurs commandes dans une même étape. Dans le Dockerfile ci-dessus, nous avons réduit le nombre de layers en réalisant le téléchargement, le désarchivage et la suppression des fichiers dans une seule commande :

  ```shell
  RUN set -x \
      && curl -fSL TOMCAT_TAR_GZ_URL -o tomcat.tar.gz \
      && tar -xvf tomcat.tar.gz --strip-components=1 \
      && rm bin/*.bat \
      && rm tomcat.tar.gz*
  ```

  Penser à ajouter le caractère d'échappement `\` à la fin de chaque nouvelle ligne.

3. Quelques commandes/alias à maîtriser pour manipuler les conteneurs Docker

  - Créer un container docker : `docker container run -it -d --name nom_container nom_tag:version_tag`

  - Se connecter à un container (console bash): `docker container exec -it nom_container bash`

  - Liste des containers : `docker container ps -a`

  - Arrêter un container : `docker container stop nom_container`

  - Supprimer un container: `docker container rm nom_container`

  Pour manipuler plus facilement les containers, on peut créer des alias dans un fichier `~/.docker_alias`

  ```shell
  #!/bin/bash
  alias dk='docker'
  # Liste des processus Docker
  alias dkps='docker ps -a'
  # Liste des containers suivant un format.
  alias dkpsf='docker ps --format '{{.ID}} ~ {{.Names}} ~ {{.Status}} ~ '{{.Image}}''
  # Visualiser les logs d'un container
  alias dkl='docker logs'
  # Logs d'un container Docker (tail -f)
  alias dklf='docker logs -f'
  # Liste des images Docker
  alias dki='docker images'
  alias dks='docker service'
  # Supprimer un container Docker
  alias dkrm='docker rm'
  # Supprimer une image Docker
  alias dkrmimage='docker rm image'
  # Créer une image Docker
  alias dkbi='docker image build . -t'
  ```

  Ensuite, ajouter les lignes ci-dessous au fichier `~/.bashrc` pour prendre en compte les alias.
  ```shell
  if [ -f ~/.docker_alias ]; then
      . ~/.docker_alias
  fi
  ```

  ## [Docker-compose](https://docs.docker.com/compose/)

  Docker Compose est un outil qui permet de décrire dans un fichier YAML (docker-compose.yml) un ensemble de conteneurs Docker. Docker-compose propose des commandes pour gérer les conteneurs comme un ensemble de services. Par exemple, dans un environnement de développement, nous pouvons avoir besoin de plusieurs conteneurs (PostgreSQL, ELK, etc...). Il faut lancer manuellement chaque conteneur avec la commande `docker container run`. Avec Docker-compose, nous pouvons démarrer (`docker-compose up`) ou arrêter (`docker-compose down`) tous les conteneurs en une seule ligne de commande.

  Sans trop tarder, nous allons installer `docker-compose` et l'utiliser dans un cas pratique.

  1. Installation

      1. Environnement

      ```
      root@pl-debian:~# uname -a
      Linux pl-debian 4.9.0-8-amd64 #1 SMP Debian 4.9.110-3+deb9u6 (2018-10-08) x86_64 GNU/Linux
      root@pl-debian:~# lsb_release -a
      No LSB modules are available.
      Distributor ID: Debian
      Description:    Debian GNU/Linux 9.5 (stretch)
      Release:        9.5
      Codename:       stretch
      ```

      2. Installation de docker-compose avec l'outil pip

      ```
      root@pl-debian:~# apt install python-pip
      root@pl-debian:~# pip install docker-compose
      ```

      3. Vérifier que docker-compose est bien installé

      ```
      root@pl-debian:~# docker-compose version
      docker-compose version 1.24.1, build 4667896
      docker-py version: 3.7.3
      CPython version: 2.7.13
      OpenSSL version: OpenSSL 1.1.0k  28 May 2019
      ```

  2. Cas d'utilisation

    Voici un exemple de fichier docker-compose.yml (fichier dosponible dans le dossier local-dev).

    ```YAML
      version: '3.6'

      services:

        postgres:
          image: postgres
          container_name: postgres
          ports:
            - "5432:5432"
          environment:
            POSTGRES_USER: root
            POSTGRES_PASSWORD: Mmdp-3325
          healthcheck:
           test: ["CMD-SHELL", "pg_isready -U postgres"]
           interval: 10s
           timeout: 5s
           retries: 5

        zookeeper:
          image: wurstmeister/zookeeper
          container_name: zookeeper
          ports:
            - "2181:2181"

        kafka:
          image: wurstmeister/kafka
          container_name: kafka
          depends_on:
            - zookeeper
          ports:
            - "9092:9092"
          environment:
            KAFKA_ADVERTISED_HOST_NAME: localhost
            KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181

        elasticsearch:
          image: elasticsearch:6.8.2
          container_name: elasticsearch
          ports:
            - "9200:9200"
            - "9300:9300"
          environment:
            - node.name=node-1
            - cluster.name=docker-cluster
            - bootstrap.memory_lock=true
            - http.cors.enabled=true
            - http.cors.allow-origin=*
            - node.master=true
            - node.data=true
            - http.port=9200
            - transport.tcp.port=9300
            - "ES_JAVA_OPTS=-Xms1g -Xmx1g"
            - MAX_LOCKED_MEMORY=unlimited
          ulimits:
            memlock:
              soft: -1
              hard: -1
    ```

    - Le service `postgres` pour fournir le SGBD PostgreSQL.

        Ce service fournit le conteneur `postgres` qui utilise l'image publique [postgres](https://hub.docker.com/_/postgres).
        Nous avons indiqué les valeurs des variables d'environnement `POSTGRES_USER` et `POSTGRES_PASSWORD` qu'on utilisera pour se connecter à la BDD. Quand on observe la configuration, on remarque que ce service reprend en quelques lignes les paramètres qu'utilise `docker` pour exécuter ou stopper un conteneur postgres manuellement.

    - Le service `zookeeper`

        `Kafka` utilise Zookeeper. Donc nous ajoutons ce service zookeeper qui sera utile à Kafka.

    - Le service `kafka`

        docker-compose va créer un service `kafka` qui dépend du service `Zookeeper`. `kafka` ne sera construit que si le service `zookeeper` est construit avec succès (`depends_on: zookeeper`).

    - Le service `elasticsearch`

        Ce service lance un conteneur `elasticsearch` accessible via les ports HTTP 9200 et TCP 9300.

  Avec docker-compose, nous définissons en quelques lignes ce qu'il faut faire manuellement avec plusieurs lignes de commandes `docker`.

  Quelques commandes `docker-compose` utiles :

    - `docker-compose up -d` : lancer tous les services présents dans le fichier `docker-compose.yml` en arrière-plan ( option `-d`) pour rendre la main à l'utilisateur.

    - `docker-compose stop` : arrêter les services

    - `docker-compose restart` : redémarrer les services

    - `docker-compose exec [nom_conteneur] /bin/bash` : fournit une console `bash` au sein du conteneur `nom_conteneur`.

    - `docker-compose logs` : fournit l'ensemble des logs de tous les services depuis le démarrage.

    - `docker-compose logs -f` : affiche les logs des services et continue à les « écouter » sans rendre la main.

    - `docker-compose logs -f [nom_conteneur]` : affiche uniquement les logs du conteneur `nom_conteneur`.

    On peut enrichir le fichier des alias avec de nouveaux alias pour manipuler `docker-compose` :

    ```shell
    # ==== Alias Docker-compose ===
    # Start the docker-compose stack in the current directory
    alias dcup="docker-compose up -d"
    # Arrêter Docker-compose
    alias dcst="docker-compose stop"
    # Arrêter Docker-compose et supprimer tous les containers.
    alias dcdo="docker-compose down"
    # Redémarrer Docker-compose
    alias dcrs="docker-compose restart"
    # Consulter les logs de la stack docker-compose
    alias dclo="docker-compose logs"
    ```

  3. Autres

        1. Etat des services de docker-compose

        ```
            legeric@pl-debian:~/local-dev$ docker-compose up -d
            Creating network "local-dev_default" with the default driver
            Creating zookeeper     ... done
            Creating elasticsearch ... done
            Creating postgres      ... done
            Creating kafka         ... done
            legeric@pl-debian:~/local-dev$ docker-compose ps
            Name                   Command               State                     Ports                       
            -----------------------------------------------------------------------------------------------------------
            elasticsearch   /usr/local/bin/docker-entr ...   Up      0.0.0.0:9200->9200/tcp, 0.0.0.0:9300->9300/tcp    
            kafka           start-kafka.sh                   Up      0.0.0.0:9092->9092/tcp                            
            postgres        docker-entrypoint.sh postgres    Up      0.0.0.0:5432->5432/tcp                            
            zookeeper       /bin/sh -c /usr/sbin/sshd  ...   Up      0.0.0.0:2181->2181/tcp, 22/tcp, 2888/tcp, 3888/tcp
        ```

        2. Kafka

          - Se connecter au conteneur/service kafka : `docker-compose exec kafka /bin/bash` ou `docker exec -it kafka`

          - Une fois connecté, créer un topic (le topic nommé `test` par exemple) kafka : `kafka-topics.sh --create --zookeeper zookeeper:2181 --replication-factor 1  --partitions 1 --topic test`

          - Consulter la liste des topics kafka : `kafka-topics.sh --list --bootstrap-server localhost:9092`

          - Décrire un topic : `kafka-topics.sh --zookeeper localhost:2181 --describe --topic test`

          - Supprimer un topic kafka :

              - Arrêter le serveur en activant l'option de suppression des topics : `kafka-server-stop.sh opt/kafka/config/server.properties --override delete.topic.enable=true`

              - Supprimer le topic : `kafka-topics.sh --zookeeper localhost:2181 --delete --topic test`

              - Liste des topic (remarquez que le topic `test` doit être supprimé) : `kafka-topics.sh --zookeeper localhost:2181 --list`

              - Redémarrer kafka : `kafka-server-start.sh opt/kafka/config/server.properties`

        3. PostgreSQL

          - Se connecter au conteneur postgres : `docker-compose exec postgres /bin/bash` ou `docker exec -it postgres /bin/bash`

          - Créer un nouvel utilisateur avec des attributs : `psql -c "CREATE USER test LOGIN password 'test' CREATEDB CREATEROLE;"`

          - Créer une base de données : `psql -c "CREATE DATABASE db_test OWNER=test;"`

          - Créer un schéma de base de données : `psql -d db_test -c "SET SEARCH_PATH TO db_test; CREATE SCHEMA db_test AUTHORIZATION test;"`
