#!/bin/bash


cd $HOME

sudo apt-get update -y
sudo apt-get install git git-delta -y
sudo apt-get install python3 -y
sudo apt-get install python3-pip -y
sudo apt-get install nodejs npm -y
sudo apt-get install jq tmux zsh ripgrep bat fd-find wget curl vim -y
sudo apt install trash-cli -y
sudo apt install -y gpg
sudo apt-get install apt-transport-https ca-certificates gnupg -y
sudo apt install software-properties-common -y
sudo apt-get install build-essential -y

sudo apt install ripgrep bat fd-find wget curl vim software-properties-common build-essential nodejs npm zip unzip -y

PYTHON_VERSION=$(python3 --version | sed -r "s/Python ([0-9]{1}\.[0-9]{2})\.[0-9]/\1/g")
sudo apt-get install python$PYTHON_VERSION-venv -y

#clone config
git clone https://github.com/JhonathanWolff/terminal.git $HOME/terminal
TERMINAL="${HOME}/terminal"


# Update Npm
sudo npm install -g n
sudo n stable
sudo npm install tree-sitter-cli -g


## wsl to use chrome or other browser
#sudo apt-get install wslu -y

#jqp TUI jq
wget https://github.com/noahgorstein/jqp/releases/download/v0.8.0/jqp_Linux_x86_64.tar.gz
tar -xf jqp_Linux_x86_64.tar.gz
sudo mv jqp /usr/bin
rm jqp jqp_Linux_x86_64.tar.gz


#fzf
git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf
yes | $HOME/.fzf/install


#starship
curl -sS https://starship.rs/install.sh > starship_install.sh
chmod +x starship_install.sh
./starship_install.sh -y
rm starship_install.sh


#zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh


#lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/


#eza
mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
sudo apt-get update -y
sudo apt-get install -y eza


sudo apt upgrade -y
wget https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.tar.gz
tar -xf nvim-linux-x86_64.tar.gz
sudo cp -r nvim-linux-x86_64/* "/usr/local/" && rm -rf nvim-linux-x86_64 nvim-linux-x86_64.tar.gz

#Install Lua
curl -L -R -O https://www.lua.org/ftp/lua-5.5.0.tar.gz && tar zxf lua-5.5.0.tar.gz && cd lua-5.5.0 && sudo make all test && sudo cp src/lua /usr/bin && sudo cp src/luac /usr/bin && sudo cp src/*.h /usr/include/

#Install luaRocks
wget https://luarocks.org/releases/luarocks-3.13.0.tar.gz &&  tar zxpf luarocks-3.13.0.tar.gz &&  cd luarocks-3.13.0 && sudo ./configure && sudo make && sudo make install &&  sudo luarocks install luasocket



#themes

#tmux
mkdir -p $HOME/.config/tmux/plugins/catppuccin
git clone -b v2.1.2 https://github.com/catppuccin/tmux.git $HOME/.config/tmux/plugins/catppuccin/tmux

# K9s
wget https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb && sudo apt install ./k9s_linux_amd64.deb && sudo  rm k9s_linux_amd64.deb


#CONFIGURACAO VARIAVEL



#gcloud

#java
#sudo apt-get install openjdk-21-jdk -y
#sudo apt-get install openjdk-21-jre -y



##------------------------

#Configura tudo
#aqui precisa estar logado

cd $HOME
sudo mkdir -p $HOME/.config/zsh/plugins
sudo cp -r $TERMINAL/nvim $HOME/.config/
sudo cp $TERMINAL/tmux/.tmux.conf $HOME/.tmux.conf
sudo cp $TERMINAL/terminal/.bashrc $HOME/.bashrc
# sudo cp -r $TERMINAL/terminal_functions $HOME
sudo cp $TERMINAL/terminal/.zshrc $HOME/.zshrc
sudo cp $TERMINAL/starship/starship.toml $HOME/.config/starship.toml


#ZSH plugins
mkdir -p $HOME/.config/zsh/plugins
sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.config/zsh/plugins/zsh-syntax-highlighting
sudo git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.config/zsh/plugins/zsh-autosuggestions
#sudo git clone https://github.com/jeffreytse/zsh-vi-mode.git $HOME/.config/zsh/plugins/zsh-vi-mode



#tmux plugin
mkdir -p $HOME/.config/tmux/plugins
git clone https://github.com/tmux-plugins/tpm $HOME/.config/tmux/plugins/tpm

source $HOME/.zshrc
clear

chsh -s $(which zsh)




