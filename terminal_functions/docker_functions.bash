#@ Docker

#: Roda container efemero de uma imagem com bash
#: Uso: docker_run_rm_terminal <imagem>
#:   <imagem>  obrigatorio. Imagem docker (ex: python:3.12)
#: Executa: docker run --rm -it --entrypoint bash <imagem>. Container removido ao sair.
function docker_run_rm_terminal {
  docker run --rm -it --entrypoint bash $1
}

#: Abre bash em um container em execucao
#: Uso: dcc
#: Lista os containers rodando (fzf) e executa docker exec -it <container> bash.
function dcc {

    container_name=$(docker ps --format '{{ .Names }}' | fzf --tmux 90%)
    docker exec -it $container_name bash
}
