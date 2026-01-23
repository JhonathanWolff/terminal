


alias python='python3'
alias open_folder='explorer.exe .'


alias fd='fdfind'
alias lg='lazygit'


#Alias WSl
alias open='explorer.exe'
alias clip='clip.exe'

#Font : FireCode Nerd Font
alias ls='eza --icons'
alias gb="git branch | fzf | xargs git checkout"
alias cowtip="fortune | cowsay"
# alias cd="z"

alias bat="batcat -p"
alias cat="batcat -p"

alias lgb="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short"

alias bash_config='vim ~/.bashrc && source ~/.bashrc && tmux source ~/.tmux.conf && UploadShellConfig'
alias zsh_config='vim ~/.zshrc && source ~/.zshrc && tmux source ~/.tmux.conf && UploadShellConfig'
alias source_bash='source ~/.bashrc && echo "bash sourced" && UploadShellConfig'
alias source_zsh='source ~/.zshrc && echo "zsh sourced" && UploadShellConfig'

#alias rm='echo utilize o comando trash ao invez de rm... && rm'


#git alias
git config --global alias.lol "log --oneline --graph --decorate"
