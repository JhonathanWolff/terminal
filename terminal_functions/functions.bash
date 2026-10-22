#@ Tools

#: Create/activate the work venv
#: Usage: work_time
#: Creates ~/work/work_envs/work_env if missing and activates it when no venv is active.
#: Also runs automatically when functions.bash is loaded.
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

#: Copy configs to the terminal repo and open lazygit
#: Usage: update_terminal
#: Copies .zshrc, .bashrc, .tmux.conf, nvim, starship, requirements.txt and lazygit config to $TERMINAL (uses sudo)
#: and opens lazygit there. Returns to the original directory on exit.
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

#: chown ~/work to the current user
#: Usage: give_owner_to_work
#: Runs sudo chown -R $USER ~/work.
function give_owner_to_work {
  sudo chown -R $USER ~/work

}

#: Query cheat.sh
#: Usage: cheat <command>
#:   <command>  required. E.g. cheat tar
function cheat {
    curl cheat.sh/$1
}

#: List functions defined in .bash files of the current directory
#: Usage: find_methods
#: Recursively searches 'function name' in .bash files from the current directory.
function find_methods {
  find .  | grep -E "\.bash$" | xargs -I {} rg -o   "function ([0-9A-z_]+)" {} | sed "s/function//g"
}

#call work_time_to_create env
work_time

#: Function documentation
#: Usage: help                    list everything, grouped by section
#:        help <section>          list one section (dataform, gcp, git, docker, tmux, tools...)
#:        help <function>         detailed documentation of the function
#:        help <section> <function>  same, restricted to the section
#: Pipe:  help | rg avro | help   show the detailed docs of every filtered function
#: Docstring: '#:' lines above 'function name' (first line = summary; the rest = details).
#: Section: '#@ Name' line at the top of the file; without it the file falls into Tools.
function help {
  local a1 a2 n
  if [[ $# -eq 0 && -p /dev/stdin ]]; then
    for n in $(sed 's/\x1b\[[0-9;]*m//g' | awk '/^  [A-Za-z_]/ {print $1}'); do help "$n"; echo; done
    return
  fi
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
      if (!found) print "help: nothing found (run help to list)"
    }'
}
