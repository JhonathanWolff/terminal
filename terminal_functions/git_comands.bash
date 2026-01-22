

function gblame {
  file_to_blame=$(fd . | fzf --tmux)
  git blame "${file_to_blame}"
}

function glola {
  git log --graph --decorate --pretty=oneline --abbrev-commit --all
}
