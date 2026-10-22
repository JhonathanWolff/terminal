#@ JavaScript


#: Instala dev deps node
#: Uso: node_install_dev
#: Se existir package.json: npm install -D @types/node e js-yaml.
function node_install_dev()
{
    if [[ -f "package.json" ]]; then
        npm install -D @types/node
        npm install -D js-yaml
    fi
}

#: Prepara projeto TypeScript
#: Uso: ts_install_dev
#: Se existir package.json instala @types/node (dev) e cria tsconfig.json
#: (ES2020, commonjs, strict, outDir ./dist, include src). Sobrescreve tsconfig.json existente.
function ts_install_dev()
{
    if [[ -f "package.json" ]]; then
        npm install -D @types/node
    fi

#Nao pode ter espaco no EOF
    cat << EOF > tsconfig.json
    {
        "compilerOptions": {
          "target": "ES2020",
          "module": "commonjs",
          "moduleResolution": "node",
          "esModuleInterop": true,
          "types": ["node"],
          "strict": true,
          "outDir": "./dist"
        },
        "include": ["src/**/*"],
        "exclude": ["node_modules"]
    }
EOF
}

#: Roda um script do package.json escolhido
#: Uso: npm_package
#: Lista os scripts (fzf; o preview mostra o comando) e executa npm run <script>.
function npm_package() {

    script=$(jq -r '.scripts | to_entries[] | .key + "##" + .value' package.json \
      | fzf-tmux -p 80%,60% -- \
            -m \
            --delimiter="##" \
            --with-nth=1 \
            --preview='echo {2}' \
            --preview-window=right:50% \
      | awk -F'##' '{print $1}')

    npm run "$script"
}

#: Servidor com live reload
#: Uso: live_server
#: Executa reload -b no diretorio atual. Requer: sudo npm i reload -g.
function live_server {
    #sudo npm i reload -g
    reload -b

}
