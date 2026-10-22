#@ Docker

#: Run a throwaway container from an image with bash
#: Usage: docker_run_rm_terminal <image>
#:   <image>  required. Docker image (e.g. python:3.12)
#: Runs: docker run --rm -it --entrypoint bash <image>. Container is removed on exit.
function docker_run_rm_terminal {
  docker run --rm -it --entrypoint bash $1
}

#: Open bash in a running container
#: Usage: dcc
#: Lists running containers (fzf) and runs docker exec -it <container> bash.
function dcc {

    container_name=$(docker ps --format '{{ .Names }}' | fzf --tmux 90%)
    docker exec -it $container_name bash
}
