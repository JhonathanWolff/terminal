#@ Tools

#: Cria/ativa a venv de trabalho
#: Uso: work_time
#: Cria ~/work/work_envs/work_env se nao existir e ativa se nenhuma venv estiver ativa.
#: Tambem roda automaticamente ao carregar functions.bash.
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

#: Copia configs para o repo do terminal e abre lazygit
#: Uso: update_terminal
#: Copia .zshrc, .bashrc, .tmux.conf, nvim, starship, requirements.txt e lazygit para $TERMINAL (usa sudo)
#: e abre o lazygit nele. Volta ao diretorio de origem ao sair.
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
#: Uso: give_owner_to_work
#: Executa sudo chown -R $USER ~/work.
function give_owner_to_work {
  sudo chown -R $USER ~/work

}

#: Consulta cheat.sh
#: Uso: cheat <comando>
#:   <comando>  obrigatorio. Ex: cheat tar
function cheat {
    curl cheat.sh/$1
}

#: Lista funcoes dos .bash do diretorio atual
#: Uso: find_methods
#: Busca recursiva por 'function nome' nos arquivos .bash a partir do diretorio atual.
function find_methods {
  find .  | grep -E "\.bash$" | xargs -I {} rg -o   "function ([0-9A-z_]+)" {} | sed "s/function//g"
}

#call work_time_to_create env
work_time

#: Documentacao das funcoes
#: Uso: help                    lista tudo, agrupado por secao
#:      help <secao>            lista so a secao (dataform, gcp, git, docker, tmux, tools...)
#:      help <funcao>           documentacao detalhada da funcao
#:      help <secao> <funcao>   idem, restringindo a secao
#: Docstring: linhas '#:' acima de 'function nome' (1a linha = resumo; demais = detalhe).
#: Secao: linha '#@ Nome' no topo do arquivo; sem ela cai em Tools.
function help {
  local a1 a2
  a1=$(printf '%s' "$1" | tr 'A-Z' 'a-z'); a2=$(printf '%s' "$2" | tr 'A-Z' 'a-z')
  awk '
    FNR==1 { sec = "Tools"; doc = "" }
    /^#@ /  { sec = substr($0, 4); next }
    /^#:/   { doc = doc (doc == "" ? "" : "\001") substr($0, 4); next }
    /^function / {
      name = $2; sub(/\(.*/, "", name)
      if (doc != "") print sec "\t" name "\t" doc
      doc = ""
    }
  ' "$HOME/terminal/terminal_functions"/*.bash | sort -t$'\t' -k1,1 -k2,2 |
  awk -F'\t' -v a1="$a1" -v a2="$a2" '
    { n++; sec[n] = $1; name[n] = $2; doc[n] = $3; if (tolower($1) == a1) isSec = 1 }
    function detail(i,   k, parts, c) {
      printf "\033[1;36m%s\033[0m \033[2m(%s)\033[0m\n", name[i], sec[i]
      c = split(doc[i], parts, "\001")
      for (k = 1; k <= c; k++) print "  " parts[k]
    }
    function list(only,   i, s, first) {
      for (i = 1; i <= n; i++) {
        if (only != "" && tolower(sec[i]) != only) continue
        if (sec[i] != s) { s = sec[i]; printf "\n\033[1;33m# %s\033[0m\n", s }
        split(doc[i], first, "\001")
        printf "  \033[1;36m%-28s\033[0m %s\n", name[i], first[1]
      }
    }
    END {
      if (a2 != "") { for (i = 1; i <= n; i++) if (tolower(sec[i]) == a1 && name[i] == a2) { detail(i); found = 1 } }
      else if (a1 == "" || isSec) { list(a1); found = 1 }
      else { for (i = 1; i <= n; i++) if (name[i] == a1) { detail(i); found = 1 } }
      if (!found) print "help: nada encontrado (use help para listar)"
    }'
}
