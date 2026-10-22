#@ Dataform

#: Mostra erros de compilacao do Dataform
#: Uso: dt_log
#: Escolhe regiao, projeto e repositorio (fzf), busca via API os compilationResults com erro
#: e abre o JSON no nvim (arquivo temporario apagado ao fechar).
function dt_log {

    REGION=$(printf "%s\n" "${GCP_REGIONS[@]}" | fzf --tmux 90% --prompt="Region for Project> ")
    PROJECT=$(gcloud projects list --format="value(projectId)" | fzf --tmux 90% --prompt="Project for Dataform> ")

    BASE_URL="https://dataform.googleapis.com/v1beta1"
    TOKEN=$(gcloud auth print-access-token)


    REPOSITORY=$(curl -H "Authorization: Bearer ${TOKEN}" "${BASE_URL}/projects/${PROJECT}/locations/${REGION}/repositories" | jq  -r ".repositories[].name" | rev | cut -d "/" -f 1 | rev | fzf --tmux 90% --prompt="Repository> ")
    HEADER="Authorization: Bearer ${TOKEN}"

    curl -H "${HEADER}" "${BASE_URL}/projects/${PROJECT}/locations/${REGION}/repositories/${REPOSITORY}/compilationResults/" | jq ".compilationResults[] | select(has(\"compilationErrors\")) | ." > "/tmp/dataform_erros.json"
    nvim "/tmp/dataform_erros.json"
    rm "/tmp/dataform_erros.json"

}

#: Salva as queries compiladas do Dataform
#: Uso: dt_querys
#: Roda dataform compile --json e grava cada tabela em ./compiled/<tabela>.sql.
function dt_querys {
    dataform compile --json > compiled.json
    mkdir -p compiled

    while IFS= read -r -d '' TABLE && IFS= read -r -d '' QUERY; do

        [[ -z "$TABLE" ]] && continue
        echo "${TABLE}"

        echo "${QUERY}" > "./compiled/${TABLE}.sql"

    done < <(jq -j '.tables[] | (.target.name, "\u0000", .query, "\u0000")' compiled.json 2>/dev/null)

    rm compiled.json
}


#: Inicializa projeto Dataform
#: Uso: dt_init
#: Recria node_modules, configura .npmrc (registry @datasync + auth do Artifact Registry), npm i,
#: dataform init-creds, corrige 'for (idTable in' nos .sqlx e ignora .df-credentials.json no git.
function dt_init {

    rm -rf node_modules/ package-lock.json
    echo "@datasync:registry=https://us-central1-npm.pkg.dev/hitchhikers-magrathea/datasync-nodejs-repository/" > ".npmrc"
    npx google-artifactregistry-auth --repo-config=./.npmrc --credential-config=./.npmrc
    if ! grep -q ".npmrc" ".gitignore";
    then
        echo -e "\n.npmrc" >> ".gitignore"
    fi

    npm i
    dataform init-creds
    fd .  | grep -E ".sqlx$" | xargs -I {} sed -i 's/for (idTable in groupTables)/for (const idTable in groupTables)/g' {}
    echo ".df-credentials.json" >> ".gitignore"

}



#: Prepara projeto Dataform para teste em schema 'test'
#: Uso: dt_config
#: Igual ao setup do dt_init (npmrc, npm i, init-creds), depois roda dt_rename (schema -> test),
#: pergunta o nome da branch, cria test/<nome>, compila e commita 'Database Rename' se compilar.
function dt_config {

    rm -rf node_modules/ package-lock.json
    echo "@datasync:registry=https://us-central1-npm.pkg.dev/hitchhikers-magrathea/datasync-nodejs-repository/" > ".npmrc"
    npx google-artifactregistry-auth --repo-config=./.npmrc --credential-config=./.npmrc
    if ! grep -q ".npmrc" ".gitignore";
    then
        echo -e "\n.npmrc" >> ".gitignore"
    fi

    npm i
    dataform init-creds

    dt_rename
    clear
    figlet -f "slant" "Dataform Tester"
    printf "%s" "Insira o nome da branch  test/"
    read branch_name


    git checkout -b "test/${branch_name}"
    dataform compile
    if [ $? -eq 0 ];then
        git add -A &>/dev/null
        git commit -m "Database Rename" &>/dev/null
    fi


}



#: Troca o schema dos arquivos Dataform para 'test'
#: Uso: dt_rename [dir]
#:   [dir]  opcional, padrao '.'. Altera *.js, *.sqlx e *.txt que tenham bloco config {}:
#: substitui ou adiciona schema:"test". Altera os arquivos no lugar (sem backup).
function dt_rename {

    DIR="${1:-.}"
    SCHEMA_VALUE="test"

    echo "Modificando arquivos em: $DIR"
    echo "Valor do schema: $SCHEMA_VALUE"
    echo "================================"

    BACKUP=false

    find "$DIR" -type f \( -name "*.js" -o -name "*.sqlx" -o -name "*.txt" \) | while read -r file; do

    if grep -q "config[[:space:]]*{" "$file"; then
        echo "Processando: $file"

        if [ "$BACKUP" = true ]; then
            cp "$file" "${file}.bak"
        fi

        if grep -A 20 "config[[:space:]]*{" "$file" | grep -q "schema:"; then
            sed -i.tmp '/config[[:space:]]*{/,/}/ s/schema:[[:space:]]*"[^"]*"/schema:"'$SCHEMA_VALUE'"/g; s/schema:[[:space:]]*'\''[^'\'']*'\''/schema:"'$SCHEMA_VALUE'"/g' "$file"
            echo "  ✓ Schema substituído"
        else
            sed -i.tmp '/config[[:space:]]*{/a\        schema:"'$SCHEMA_VALUE'",' "$file"
            echo "  ✓ Schema adicionado"
        fi

        rm -f "${file}.tmp"
    fi
    done

    for FILE_NAME in $(rg -l "schema:" | grep "sqlx");
    do
        sed -i "s/schema:.*/schema:\"test\",/" "${FILE_NAME}"
    done

    echo "================================"


}

#: Salva as queries compiladas do Dataform (nome completo)
#: Uso: dtc
#: Como dt_querys, mas grava em ./compiled/<projeto>.<schema>.<tabela>.sql e adiciona compiled/ ao .gitignore.
function dtc {

    OLD_IFS=$IFS
    IFS=$'\n'

    mkdir -p compiled

    if  ! cat .gitignore | grep -q "compiled/";
    then
        echo -e "\ncompiled/" >> ".gitignore"
    fi

    dataform compile --json 2>/dev/null |  jq -c ".tables[]" |  while IFS= read -r info; do

    schema=$(printf '%s\n' "${info}" | jq -r ".target.schema")
    table_name=$(printf '%s\n' "${info}" | jq -r ".target.name")
    project=$(printf '%s\n' "${info}" | jq -r ".target.database")
    query=$(printf '%s\n' "${info}" | jq -r ".query")
    echo -e "${query}" > "./compiled/${project}.${schema}.${table_name}.sql"

    done

    IFS=$OLD_IFS


}

#: Usa @datasync/dataform_package local via npm link
#: Uso: dt_link_lib
#: Faz unlink, remove node_modules/package-lock e roda npm link. Depois remova o pacote do package.json e rode npm i.
function dt_link_lib {


    npm unlink @datasync/dataform_package --no-save
    rm -rf node_modules package-lock.json
    npm link @datasync/dataform_package
    echo "Remova o pacote da depencia do package.json e rode npm i"
}


