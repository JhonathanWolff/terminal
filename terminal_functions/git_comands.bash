

function gblame {
  file_to_blame=$(fd . | fzf --tmux)
  git blame "${file_to_blame}" | fzf
}

function glola {
  git log --graph --decorate --pretty=oneline --abbrev-commit --all
}

function gitinspect {

    echo "\n---Repo Maintainers----"
    git shortlog -sn --no-merges

    echo "\n------What Changes the Most-----"
    git log --format=format: --name-only --since="1 year ago" | sort | uniq -c | sort -nr | head -20


    echo "\n---Files with bugs-----"
    git log -i -E --grep="fix|bug|broken" --name-only --format='' | sort | uniq -c | sort -nr | head -20


    echo "\n---Emergencial Hotfixes----"
    git log --oneline --since="1 year ago" | grep -iE 'revert|hotfix|emergency|rollback'
}
