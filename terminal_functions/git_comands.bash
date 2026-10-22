#@ Git


#: Escolhe arquivo (fzf) e mostra git blame
function gblame {
  file_to_blame=$(fd . | fzf --tmux)
  git blame "${file_to_blame}" | fzf
}

#: Grafo de commits de todas as branches
function glola {
  git log --graph --decorate --pretty=oneline --abbrev-commit --all
}

#: Resumo do repo: autores, arquivos mais alterados, bugs, hotfixes
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

#: Navega commits com fzf e mostra o diff no preview
function git_diff {
  git log --oneline --all --pretty=format:"%h" | fzf --tmux 90%  --preview "git diff --color=always {}" --preview-window='up:95%'  --bind ctrl-j:preview-page-up,ctrl-k:preview-page-down
}

#: Escolhe repo wms/wppmedia da VMLYR (fzf) e clona
function github_clone {

  repository_name=$(gh repo list VMLYR --json name -L 1000 -q '.[] | select(.name | test("wms|wppmedia-")) | .name' | fzf --tmux 90% )
  git clone git@github.com:VMLYR/$repository_name.git
  cd "${repository_name}"

}
