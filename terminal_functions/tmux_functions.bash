#@ Tmux

#: Cria sessoes tmux padrao e anexa em uma (fzf)
function ts {

    tmux new-session -d -s "python"
    tmux new-session -d -s "bash"
    tmux new-session -d -s "java"
    tmux new-session -d -s "docs"
    tmux a -t $(tmux ls | grep : | cut -d : -f1 | fzf --tmux 90%)

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
