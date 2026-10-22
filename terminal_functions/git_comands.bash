#@ Git


#: Git blame de um arquivo escolhido
#: Uso: gblame
#: Escolhe o arquivo (fzf) e mostra git blame navegavel em fzf.
function gblame {
  file_to_blame=$(fd . | fzf --tmux)
  git blame "${file_to_blame}" | fzf
}

#: Grafo de commits de todas as branches
#: Uso: glola
#: git log --graph --decorate, uma linha por commit, todas as branches.
function glola {
  git log --graph --decorate --pretty=oneline --abbrev-commit --all
}

#: Resumo de saude do repo
#: Uso: gitinspect
#: Mostra: autores (shortlog), 20 arquivos mais alterados no ultimo ano, 20 arquivos com commits fix/bug/broken
#: e commits recentes de revert/hotfix/emergency/rollback.
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

#: Navega commits e mostra o diff de cada um
#: Uso: git_diff
#: Lista commits de todas as branches (fzf); o preview mostra o git diff do commit selecionado.
function git_diff {
  git log --oneline --all --pretty=format:"%h" | fzf --tmux 90%  --preview "git diff --color=always {}" --preview-window='up:95%'  --bind ctrl-j:preview-page-up,ctrl-k:preview-page-down
}

#: Clona repo da org VMLYR (wms|wppmedia-) e entra nele
#: Uso: github_clone
#: Lista os repos da VMLYR que casam wms ou wppmedia- (fzf), faz git clone via SSH e entra na pasta.
function github_clone {

  repository_name=$(gh repo list VMLYR --json name -L 1000 -q '.[] | select(.name | test("wms|wppmedia-")) | .name' | fzf --tmux 90% )
  git clone git@github.com:VMLYR/$repository_name.git
  cd "${repository_name}"

}
