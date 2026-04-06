

#nvim x86

apt update -y && apt install sudo -y
sudo apt install ripgrep bat fd-find wget curl vim software-properties-common build-essential nodejs npm zip unzip git -y
sudo npm install -g n && sudo n stable && sudo npm install tree-sitter-cli -g

cd $HOME
NVIM_VERSION="0.12.0"

wget "https://github.com/neovim/neovim/releases/download/v0${NVIM_VERSION}/nvim-linux-x86_64.tar.gz"

tar -xf nvim-linux-x86_64
sudo cp nvim-linux-x86_64/bin/nvim /usr/local/bin

git clone git@github.com:JhonathanWolff/nvim.git $HOME/.config/nvim
rm -rf nvim-linux-x86_64

cd $HOME && curl -L -R -O https://www.lua.org/ftp/lua-5.5.0.tar.gz && tar zxf lua-5.5.0.tar.gz && cd lua-5.5.0 && sudo make all test && sudo cp src/lua /usr/bin && sudo cp src/luac /usr/bin && sudo cp src/*.h /usr/include/ && cd $HOME && rm -rf lua-5.5.0 lua-5.5.0.tar.gz
cd $HOME && wget https://luarocks.org/releases/luarocks-3.13.0.tar.gz &&  tar zxpf luarocks-3.13.0.tar.gz &&  cd luarocks-3.13.0 && sudo ./configure && sudo make && sudo make install &&  sudo luarocks install luasocket && cd $HOME && rm -rf luarocks-3.13.0 luarocks-3.13.0.tar.gz
