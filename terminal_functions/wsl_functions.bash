
#: Imprime o pwd no formato de caminho Windows (\\wsl.localhost)
function wpwd {

    prefix="\\wsl.localhost\Ubuntu"
    new_dir=$( pwd | sed "s#/#\\\#g")
    printf "%s" "\\\\wsl.localhost\Ubuntu${new_dir}"
}
