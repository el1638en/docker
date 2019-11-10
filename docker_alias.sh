#!/bin/bash
# === Alias Docker ===
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
# Liste des containers
alias dcps="docker-compose ps -a"
