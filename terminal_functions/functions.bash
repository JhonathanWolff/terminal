#@ Tools

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

#: Consulta cheat.sh: cheat <comando>
function cheat {
    curl cheat.sh/$1
}

#: Lista as funcoes definidas nos .bash do diretorio atual
function find_methods {
  find .  | grep -E "\.bash$" | xargs -I {} rg -o   "function ([0-9A-z_]+)" {} | sed "s/function//g"
}

#call work_time_to_create env
work_time

#: Lista funcoes com descricao; filtra por secao: help [dataform|gcp|git|tools]
function help {
  awk -v f="$(printf '%s' "$1" | tr 'A-Z' 'a-z')" '
    FNR==1 { sec = "Tools"; desc = "" }
    /^#@ /  { sec = substr($0, 4); next }
    /^#: /  { desc = substr($0, 4); next }
    /^function / {
      name = $2; sub(/\(.*/, "", name)
      if (desc != "" && (f == "" || tolower(sec) == f)) print sec "\t" name "\t" desc
      desc = ""
    }
  ' "$HOME/terminal/terminal_functions"/*.bash | sort -t$'\t' -k1,1 -k2,2 |
  awk -F'\t' '$1 != s { s = $1; printf "\n\033[1;33m# %s\033[0m\n", s } { printf "  \033[1;36m%-28s\033[0m %s\n", $2, $3 }'
}
