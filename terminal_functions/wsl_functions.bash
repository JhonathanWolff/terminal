#@ WSL

#: pwd no formato de caminho Windows
#: Uso: wpwd
#: Imprime \\wsl.localhost\Ubuntu\<pwd> para colar no Explorer.
function wpwd {

    prefix="\\wsl.localhost\Ubuntu"
    new_dir=$( pwd | sed "s#/#\\\#g")
    printf "%s" "\\\\wsl.localhost\Ubuntu${new_dir}"
}
