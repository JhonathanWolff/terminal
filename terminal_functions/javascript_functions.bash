

function node_install_dev()
{
    if [[ -f "package.json" ]]; then
        npm install -D @types/node
        npm install -D js-yaml
    fi
}

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
