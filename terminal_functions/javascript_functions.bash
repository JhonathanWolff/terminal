#@ JavaScript


#: Install node dev dependencies
#: Usage: node_install_dev
#: If package.json exists: npm install -D @types/node and js-yaml.
function node_install_dev()
{
    if [[ -f "package.json" ]]; then
        npm install -D @types/node
        npm install -D js-yaml
    fi
}

#: Set up a TypeScript project
#: Usage: ts_install_dev
#: If package.json exists, installs @types/node (dev) and creates tsconfig.json
#: (ES2020, commonjs, strict, outDir ./dist, include src). Overwrites an existing tsconfig.json.
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

#: Run a chosen package.json script
#: Usage: npm_package
#: Lists the scripts (fzf; the preview shows the command) and runs npm run <script>.
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

#: Live reload server
#: Usage: live_server
#: Runs reload -b in the current directory. Requires: sudo npm i reload -g.
function live_server {
    #sudo npm i reload -g
    reload -b

}
