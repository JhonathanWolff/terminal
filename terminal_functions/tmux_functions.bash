#@ Tmux

#: Cria sessoes tmux padrao e anexa em uma
#: Uso: ts
#: Cria (detached) as sessoes python, bash, java e docs e anexa na escolhida (fzf).
function ts {

    tmux new-session -d -s "python"
    tmux new-session -d -s "bash"
    tmux new-session -d -s "java"
    tmux new-session -d -s "docs"
    tmux a -t $(tmux ls | grep : | cut -d : -f1 | fzf --tmux 90%)

}

#: Anexa em uma sessao tmux existente
#: Uso: ta
#: Escolhe a sessao (fzf) e anexa. Precisa ser executado fora de uma sessao tmux.
function ta {

  if [ -z $TMUX ];
  then
    tmux a -t $(tmux ls | grep : | cut -d : -f1 | fzf --tmux 90%)
  else
    echo "you must be out of a tmux session"
  fi

}
