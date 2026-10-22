#@ WSL

#: pwd as a Windows path
#: Usage: wpwd
#: Prints \\wsl.localhost\Ubuntu\<pwd> to paste into Explorer.
function wpwd {

    prefix="\\wsl.localhost\Ubuntu"
    new_dir=$( pwd | sed "s#/#\\\#g")
    printf "%s" "\\\\wsl.localhost\Ubuntu${new_dir}"
}
