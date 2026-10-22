
#: Roda container efemero de uma imagem com bash
function docker_run_rm_terminal {
  docker run --rm -it --entrypoint bash $1
}

#: Cria/ativa a venv de trabalho (~/work/work_envs)
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


#: Escolhe um container docker (fzf) e abre bash nele
function dcc {

    container_name=$(docker ps --format '{{ .Names }}' | fzf --tmux 90%)
    docker exec -it $container_name bash
}


#: Copia configs (zsh, bash, tmux, nvim...) para o repo e abre lazygit
function update_terminal {

  current_dir=$(pwd)
  sudo cp ~/.zshrc $HOME/terminal/terminal/.zshrc
  sudo cp ~/.bashrc $HOME/terminal/terminal/.bashrc
  sudo cp ~/.tmux.conf $HOME/terminal/tmux/.tmux.conf
  sudo cp -r ~/.config/nvim $HOME/terminal/
  sudo cp $STARSHIP_CONFIG $HOME/terminal/starship/starship.toml
  sudo cp $HOME/work/work_envs/requirements.txt $HOME/terminal/terminal_python/requirements.txt
  sudo cp $HOME/.config/lazygit/config.yml $HOME/terminal/lazygit/config.yml

  cd $TERMINAL
  lazygit

  #cd $HOME/.config/nvim
  #lazygit

  # find . | grep -E "(/__pycache__$|\.pyc$|\.pyo$)" | xargs rm -rf
  # git add --all
  # git commit -m "Updated Shell config" --quiet
  # git push --quiet

  cd $current_dir

}


#: chown de ~/work para o usuario atual
function give_owner_to_work {
  sudo chown -R $USER ~/work

}

#: Escolhe repo wms/wppmedia da VMLYR (fzf) e clona
function github_clone {

  repository_name=$(gh repo list VMLYR --json name -L 1000 -q '.[] | select(.name | test("wms|wppmedia-")) | .name' | fzf --tmux 90% )
  git clone git@github.com:VMLYR/$repository_name.git
  cd "${repository_name}"

}


#: Cria sessoes tmux padrao e anexa em uma (fzf)
function ts {

    tmux new-session -d -s "python"
    tmux new-session -d -s "bash"
    tmux new-session -d -s "java"
    tmux new-session -d -s "docs"
    tmux a -t $(tmux ls | grep : | cut -d : -f1 | fzf --tmux 90%)

}
#: Consulta cheat.sh: cheat <comando>
function cheat {
    curl cheat.sh/$1
}


#: Anexa em uma sessao tmux existente (fzf)
function ta {

  if [ -z $TMUX ];
  then
    tmux a -t $(tmux ls | grep : | cut -d : -f1 | fzf --tmux 90%)
  else
    echo "you must be out of a tmux session"
  fi

}


#: Navega commits com fzf e mostra o diff no preview
function git_diff {
  git log --oneline --all --pretty=format:"%h" | fzf --tmux 90%  --preview "git diff --color=always {}" --preview-window='up:95%'  --bind ctrl-j:preview-page-up,ctrl-k:preview-page-down
}

#: Lista as funcoes definidas nos .bash do diretorio atual
function find_methods {
  find .  | grep -E "\.bash$" | xargs -I {} rg -o   "function ([0-9A-z_]+)" {} | sed "s/function//g"
}

#: Inicia servidor com live reload (reload -b)
function live_server {
    #sudo npm i reload -g
    reload -b

}

#: Converte CRLF para LF em todos os arquivos (dos2unix)
function crl_to_lf {
    fd . -t f | xargs dos2unix
}

#: Conta frequencia de palavras de um arquivo: count_word <arquivo>
function count_word {
    tr -s '[:space:]' '\n' < "$1" | sort | uniq -c | sort -nr
}

#call work_time_to_create env
work_time

#: Lista todas as funcoes deste diretorio com descricao (docstring "#:" acima da funcao)
function help {
  awk '
    /^#: /      { desc = substr($0, 4); next }
    /^function / { name = $2; sub(/\(.*/, "", name); if (desc != "") printf "\033[1;36m%-28s\033[0m %s\n", name, desc; desc = "" }
  ' "$HOME/terminal/terminal_functions"/*.bash | sort
}
