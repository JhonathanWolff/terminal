#@ Docker

#: Roda container efemero de uma imagem com bash
function docker_run_rm_terminal {
  docker run --rm -it --entrypoint bash $1
}

#: Escolhe um container docker (fzf) e abre bash nele
function dcc {

    container_name=$(docker ps --format '{{ .Names }}' | fzf --tmux 90%)
    docker exec -it $container_name bash
}
