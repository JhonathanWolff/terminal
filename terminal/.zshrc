
zmodload zsh/datetime
_timer_start=$EPOCHREALTIME
_elapsed() {
    return
    echo "${1}: $(( (EPOCHREALTIME - _timer_start) * 1000 ))ms"
    _timer_start=$EPOCHREALTIME
}



for file in $HOME/terminal/terminal_functions/*;
do
    if echo "${file}" | grep -Eq "\.(bash|env)$";
    then
        source "${file}"
    fi
done

_elapsed "Functions Loaded"


ZSH_CUSTOM="$HOME/.config/zsh"

#https://github.com/zsh-users/zsh-autosuggestions
#https://github.com/zsh-users/zsh-syntax-highlighting
for plugin in $(ls $ZSH_CUSTOM/plugins);
do
    source "$ZSH_CUSTOM/plugins/$plugin/$plugin.zsh"
done
_elapsed "ZSH Loaded"


#vim terminal plugin

bindkey '^ ' autosuggest-accept

#gpg
export GPG_TTY=$(tty)


#active starship
eval "$(starship init zsh)"
_elapsed "startship Loaded"

#git ssh
eval $(ssh-agent) &>/dev/null
_elapsed "ssh Loaded"


#zoxide
#eval "$(zoxide init zsh)"
_zoxide_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh_inits/zoxide.zsh"
if [[ ! -f "$_zoxide_cache" || $(command -v zoxide) -nt "$_zoxide_cache" ]]; then
    mkdir -p "${_zoxide_cache:h}"
    zoxide init zsh >| "$_zoxide_cache"
fi
source "$_zoxide_cache"
_elapsed "zoxide Loaded"


#fzf

if [[ ! "$PATH" == */home/jwolff/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/jwolff/.fzf/bin"
fi
#source <(fzf --zsh)

_fzf_cache="${XDG_CACHE_HOME:-$HOME/.cache}/zsh_inits/fzf.zsh"
if [[ ! -f "$_fzf_cache" || $(command -v fzf) -nt "$_fzf_cache" ]]; then
    mkdir -p "${_fzf_cache:h}"
    fzf --zsh >| "$_fzf_cache"
fi
source "$_fzf_cache"
_elapsed "fzf Loaded"
