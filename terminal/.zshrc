
# source ~/.terminal_conf/.env
# source ~/.terminal_conf/exports.bash
# source ~/.terminal_conf/alias.bash
# source ~/.terminal_conf/functions.bash
# source ~/.terminal_conf/gcp_functions.bash
# source ~/.terminal_conf/gcp_checks.bash

for file in $HOME/terminal/terminal_functions/*;
do
    if echo "${file}" | grep -Eq "\.(bash|env)$";
    then
        source "${file}"
    fi
done



ZSH_CUSTOM="$HOME/.config/zsh"

#https://github.com/zsh-users/zsh-autosuggestions
#https://github.com/zsh-users/zsh-syntax-highlighting
for plugin in $(ls $ZSH_CUSTOM/plugins);
do
    source "$ZSH_CUSTOM/plugins/$plugin/$plugin.zsh"
done


#vim terminal plugin

bindkey '^ ' autosuggest-accept

#gpg
export GPG_TTY=$(tty)


#active starship
eval "$(starship init zsh)"

#git ssh
eval $(ssh-agent) &>/dev/null


#zoxide
eval "$(zoxide init zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

source <(fzf --zsh)
