export COMPOSE_HTTP_TIMEOUT=60000

alias dc="docker-compose"

stopcontainers() {
  docker stop $(docker ps -a -q)
}
removecontainers() {
  docker rm $(docker ps -a -f status=exited -q)
}
removeimages() {
  docker rmi $(docker images -a -q)
}

# alias dockerenv="eval \"$(docker-machine env default)\""
# alias dinghyenv="eval \"$(dinghy env)\""
# dinghyenv
