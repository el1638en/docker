# Choisir l'image sur laquelle on se base pour créer cette image.
FROM postgres:latest

# Auteur de l'image
LABEL description="Postgres SGBD" \
      maintainer="Eric LEGBA - eric.legba@gmail.com"

COPY initDb.sql /docker-entrypoint-initdb.d/
