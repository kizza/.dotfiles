export COMPOSE_HTTP_TIMEOUT=60000

alias dc="docker-compose"
alias stopcontainers="docker stop $(docker ps -a -q)"
alias removecontainers="docker rm $(docker ps -a -f status=exited -q)"
alias removeimages="docker rmi $(docker images -a -q)"

# alias dockerenv="eval \"$(docker-machine env default)\""
# alias dinghyenv="eval \"$(dinghy env)\""
# dinghyenv
