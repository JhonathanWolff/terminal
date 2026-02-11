
function docker_run_rm_terminal {
  docker run --rm -it --entrypoint bash $1
}

function work_time {

    if [[ ! -d "$HOME/work/work_envs" ]];then
        echo "Venv Nao existe criando uma nova"
        current_dir=$(pwd)
        mkdir -p $HOME/work/work_envs
        cd $HOME/work/work_envs
        python3 -m venv work_env
        cd $current_dir
    fi

  if [[ -z "$VIRTUAL_ENV" ]]; then
    source $HOME/work/work_envs/work_env/bin/activate
  fi

}


# navegacao
function ow {
  z $WORK
  fzf_file=$(  fd -E "**__pycache__**" -E "**firestore_allprojects**" -E "**/dataflow/**/**target**"  -I  | fzf --tmux 90% -i --preview 'if [ -d {} ]; then tree {}; else batcat --color=always --style=plain {}; fi' --bind ctrl-j:preview-page-up,ctrl-k:preview-page-down)
  if [ -d $fzf_file ];
  then
    z "${fzf_file}"
  else
    fzf_folder=$(dirname "$fzf_file")
    z "${fzf_folder}"
  fi

  z .

}


function oc {
  fzf_file=$(  fd -E "**__pycache__**" -E "**firestore_allprojects**" -E "**/dataflow/**/**target**" -E "**.git/**"  -HI  | fzf --tmux 90% -i --preview 'if [ -d {} ]; then tree {}; else batcat --color=always --style=plain {}; fi' --bind ctrl-j:preview-page-up,ctrl-k:preview-page-down)
  if [ -d $fzf_file ];
  then
    z "${fzf_file}"
  else
    fzf_folder=$(dirname "$fzf_file")
    z "${fzf_folder}"
  fi

  z .

}


function oo {
  fzf_file=$(rg --ignore-case  --line-number --no-heading --no-ignore-vcs . | fzf --tmux 90% --delimiter ':' --preview "batcat --color=always {1} --highlight-line {2}"  --preview-window ~8,+{2}-5 --bind ctrl-j:preview-page-up,ctrl-k:preview-page-down)
  fzf_file=${fzf_file%%:*}
  fzf_file=$(pwd)/$fzf_file


  if [ -d $fzf_file ];
  then
    z "${fzf_file}"
  else
    fzf_folder=$(dirname "$fzf_file")
    z "${fzf_folder}"
  fi

  z .
  nvim $fzf_file

}

function dcc {

    container_name=$(docker ps --format '{{ .Names }}' | fzf --tmux 90%)
    docker exec -it $container_name bash
}


function update_terminal {

  current_dir=$(pwd)
  sudo cp ~/.zshrc $HOME/terminal/terminal/.zshrc
  sudo cp ~/.bashrc $HOME/terminal/terminal/.bashrc
  sudo cp ~/.tmux.conf $HOME/terminal/tmux/.tmux.conf
  sudo cp -r ~/.config/nvim $HOME/terminal/
  sudo cp $STARSHIP_CONFIG $HOME/terminal/starship/starship.toml
  sudo cp $HOME/work/work_envs/requirements.txt $HOME/terminal/terminal_python/requirements.txt

  cd $TERMINAL
  lazygit

  # find . | grep -E "(/__pycache__$|\.pyc$|\.pyo$)" | xargs rm -rf
  # git add --all
  # git commit -m "Updated Shell config" --quiet
  # git push --quiet

  cd $current_dir

}


function give_owner_to_work {
  sudo chown -R $USER ~/work

}

function github_clone {

  repository_name=$(gh repo list VMLYR --json name -L 1000 -q '.[] | select(.name | contains("wms-")) | .name' | fzf --tmux 90% )
  git clone git@github.com:VMLYR/$repository_name.git
  cd "${repository_name}"

}

function send_files_to_docker {

  docker_image=$(docker ps --format "{{.Names}}" | fzf)
  docker_path=$(docker exec megalistav2-dataflow-megalistav2-1  find / -type d -not -path "__pycache__" -depth -maxdepth 1 | fzf --tmux --prompt="Path no docker destino>")

  for file_name in $(fdfind . -t f | fzf --tmux -m --prompt="Selecione os arquivos>");
  do
    docker_fname=$( echo "${file_name}" | rev | cut -d "/" -f 1 | rev)
    docker cp "${file_name}" "${docker_image}:${docker_path}/${docker_fname}"
  done

}

function send_current_directory_to_docker {

  docker_image=$(docker ps --format "{{.Names}}" | fzf)
  docker_path=$(docker exec megalistav2-dataflow-megalistav2-1  find / -type d -not -path "__pycache__" -depth -maxdepth 1 | fzf --tmux --prompt="Path no docker destino>")
  docker cp ${$(pwd)} "${docker_image}:${docker_path}"

}


function ts {

    tmux new-session -d -s "python"
    tmux new-session -d -s "bash"
    tmux new-session -d -s "java"
    tmux new-session -d -s "docs"
    tmux a -t $(tmux ls | grep : | cut -d : -f1 | fzf --tmux 90%)

}
function cheat {
    curl cheat.sh/$1
}


function ta {

  if [ -z $TMUX ];
  then
    tmux a -t $(tmux ls | grep : | cut -d : -f1 | fzf --tmux 90%)
  else
    echo "you must be out of a tmux session"
  fi

}



function fjq {
  echo "" | fzf --tmux 90% --phony --print-query  --preview "jq --color-output  {q} < $1 " --preview-window='up:95%'
}

function git_diff {
  git log --oneline --all --pretty=format:"%h" | fzf --tmux 90%  --preview "git diff --color=always {}" --preview-window='up:95%'  --bind ctrl-j:preview-page-up,ctrl-k:preview-page-down
}

function find_methods {
  find .  | grep -E "\.bash$" | xargs -I {} rg -o   "function ([0-9A-z_]+)" {} | sed "s/function//g"
}

function live_server {
    #sudo npm i reload -g
    reload

}


#call work_time_to_create env
work_time
