
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

function dt_link_lib {


    npm unlink @datasync/dataform_package --no-save
    rm -rf node_modules package-lock.json
    npm link @datasync/dataform_package
    echo "Remova o pacote da depencia do package.json e rode npm i"
}


