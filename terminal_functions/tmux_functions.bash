#@ Tmux

#: Create the default tmux sessions and attach to one
#: Usage: ts
#: Creates (detached) the python, bash, java and docs sessions and attaches to the chosen one (fzf).
function ts {

    tmux new-session -d -s "python"
    tmux new-session -d -s "bash"
    tmux new-session -d -s "java"
    tmux new-session -d -s "docs"
    tmux a -t $(tmux ls | grep : | cut -d : -f1 | fzf --tmux 90%)

}

#: Attach to an existing tmux session
#: Usage: ta
#: Picks the session (fzf) and attaches. Must be run outside a tmux session.
function ta {

  if [ -z $TMUX ];
  then
    tmux a -t $(tmux ls | grep : | cut -d : -f1 | fzf --tmux 90%)
  else
    echo "you must be out of a tmux session"
  fi

}
