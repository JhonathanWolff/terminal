#@ Git


#: Git blame of a chosen file
#: Usage: gblame
#: Picks the file (fzf) and shows git blame in a browsable fzf.
function gblame {
  file_to_blame=$(fd . | fzf --tmux)
  git blame "${file_to_blame}" | fzf
}

#: Commit graph of all branches
#: Usage: glola
#: git log --graph --decorate, one line per commit, all branches.
function glola {
  git log --graph --decorate --pretty=oneline --abbrev-commit --all
}

#: Repo health summary
#: Usage: gitinspect
#: Shows: authors (shortlog), top 20 files changed in the last year, top 20 files with fix/bug/broken commits,
#: and recent revert/hotfix/emergency/rollback commits.
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

#: Browse commits and show each one's diff
#: Usage: git_diff
#: Lists commits from all branches (fzf); the preview shows the git diff of the selected commit.
function git_diff {
  git log --oneline --all --pretty=format:"%h" | fzf --tmux 90%  --preview "git diff --color=always {}" --preview-window='up:95%'  --bind ctrl-j:preview-page-up,ctrl-k:preview-page-down
}

#: Clone a VMLYR repo (wms|wppmedia-) and cd into it
#: Usage: github_clone
#: Lists VMLYR repos matching wms or wppmedia- (fzf), runs git clone over SSH and enters the folder.
function github_clone {

  repository_name=$(gh repo list VMLYR --json name -L 1000 -q '.[] | select(.name | test("wms|wppmedia-")) | .name' | fzf --tmux 90% )
  git clone git@github.com:VMLYR/$repository_name.git
  cd "${repository_name}"

}
