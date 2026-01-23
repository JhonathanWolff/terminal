#This file contains all the functions that are used to interact with GCP and magrathea enviroment

GCP_REGIONS=(
"southamerica-west1"
"asia-northeast1"
"me-central2"
"us-south1"
"us-east5"
"asia-southeast2"
"us-east1"
"southamerica-east1"
"europe-west1"
"europe-central2"
"europe-west10"
"europe-southwest1"
"asia-south1"
"us-east4"
"europe-west8"
"asia-southeast1"
"europe-west2"
"us-west3"
"europe-west3"
"asia-northeast2"
"northamerica-south1"
"australia-southeast2"
"europe-west9"
"europe-west6"
"me-central1"
"africa-south1"
"me-west1"
"northamerica-northeast2"
"europe-north2"
"asia-northeast3"
"europe-west12"
"asia-east2"
"asia-east1"
"australia-southeast1"
"us-west2"
"northamerica-northeast1"
"europe-north1"
"asia-south2"
"us-west4"
"us-west1"
"us-central1"
"europe-west4"
  )


function cloudbuild_submit_trigger {

  REGION="us-central1"
  TRIGGERS=()

  for PROJECT_ID in $(gcloud projects list --format="value(projectId)" | fzf --tmux -m);
  do

    if  echo "${PROJECT_ID}" | grep -q "tegra";
    then
      echo "PROJETO DE TEGRA NA DA PRA USAR O BUILD AINDA!"
      exit 0
    fi

    if [[ -z "${TRIGGERS[@]}" ]]; then
      for TRIGGER_NAME in $(gcloud builds triggers list --region="$REGION" --project "${PROJECT_ID}" --format="value(name)" | fzf --tmux -m);
      do
        TRIGGERS+=("${TRIGGER_NAME}")
      done
    fi

    for EXECUTE_TRIGGER in "${TRIGGERS[@]}";
    do
      echo "${EXECUTE_TRIGGER} --> ${PROJECT_ID}"
      gcloud builds triggers run "${EXECUTE_TRIGGER}" --branch=main --project="${PROJECT_ID}" --region="${REGION}" --substitutions="_FORCE_BUILD=true" --branch=main 1>/dev/null
    done

  done

}



function gcp_curl_post {

    REGION="us-central1"
    PROJECT=$(gcloud projects list --format="value(projectId)" | fzf --tmux 90% --prompt="Selecione o Projeto> ")
    PAYLOAD_PATH="$HOME/.payloads"
    mkdir -p "${PAYLOAD_PATH}" 
    while getopts "s:n:r:" flag;
    do
        case "${flag}" in
          n)
            nvim "${PAYLOAD_PATH}/${OPTARG}"
            ;;
          r)
            REGION="${OPTARG}"
            ;;
          s)

            SCHEDULER=$(gcloud scheduler jobs list --project $PROJECT --format=json --filter="httpTarget.httpMethod:POST" --location=$REGION | jq -r '.[].httpTarget.body' 2>/dev/null)
            PAYLOAD=$(echo "${SCHEDULER}" | fzf --tmux 90%  --preview="echo {} | base64 -d | jq -C")
            echo "${PAYLOAD}" | base64 -d | jq > "${PAYLOAD_PATH}/${OPTARG}"
            nvim "${PAYLOAD_PATH}/${OPTARG}"

            ;;
          *)
            echo "-n <FILE NAME>  (will create a new empty file)"
            echo "-s <FILE NAME> (will check scheduler of the project for a payload)"
            return 1
            ;;
        esac
    done


    ARRAY_FILES=($(find $PAYLOAD_PATH -type f))

    URL=$(gcloud functions list --project $PROJECT --format="value(url)" | fzf --tmux 90%)
    TOKEN=$(gcloud auth print-identity-token)

    for PAYLOAD_FILE in $( for item in "${ARRAY_FILES[@]}"; do echo $item ; done | fzf --tmux 90% -m --preview="batcat --color always {}" --prompt="Selecione o payload> ");
    do
      nvim $PAYLOAD_FILE
      PAYLOAD=$(cat $PAYLOAD_FILE)
      echo $PAYLOAD | jq 
      curl -X POST "$URL" \
      -H "Authorization: bearer $(gcloud auth print-identity-token)" \
      -H "Content-Type: application/json" \
      -d "${PAYLOAD}"

    done


}


function gcp_sa_impersonate {
  FILE=$1
  CURRENT_DIR=$(pwd)
  gcloud auth revoke
  gcloud auth application-default revoke
  gcloud auth activate-service-account  $( cat "${CURRENT_DIR}/${FILE}" | jq -r '.client_email' ) --key-file="${CURRENT_DIR}/${FILE}" 
}

function iam_add {

    if [ $# -eq 0 ];
    then
      UPDATE_CACHE=""
    else
      UPDATE_CACHE=$1
    fi

    if [ "${UPDATE_CACHE}" = "-u" ];
    then
      echo "Clearing Roles Cache..."
      rm "${HOME}/terminal/terminal_functions/gcp_roles.json"
    fi
    
   if [ ! -e "${HOME}/terminal/terminal_functions/gcp_roles.json" ];
   then
     echo "Populating GCP Roles...."
     gcloud iam roles list --format=json | jq -c '.[]'  >> "${HOME}/terminal/terminal_functions/gcp_roles.json"
     echo "Populating GCP Organization Roles...."
     gcloud iam roles list --organization 239620507249 --format=json | jq -c '.[]'  >> "${HOME}/terminal/terminal_functions/gcp_roles.json"
   fi

    PROJECTS=$(gcloud projects list --format="value(PROJECT_ID)" | fzf --tmux 90% -m --prompt="Projetos> ")
    ROLES=$(
    jq -r '. | .title +" >" + .name ' "${HOME}/terminal/terminal_functions/gcp_roles.json" | \
    fzf -m --tmux 90% --prompt='Roles> ' \
    --preview-window=bottom:15% \
      --preview "selected_name=\$(echo {} | cut -d '>' -f 2); \
                jq -r --arg name \"\$selected_name\" 'select(.name == \$name) | .description' ${HOME}/terminal/terminal_functions/gcp_roles.json"
              )
    PROJECTS=($(echo $PROJECTS))
    ROLES=$( echo $ROLES | cut -d '>' -f 2)
    ROLES=($(echo $ROLES))
    echo "Roles to add..."
    for PRINT_ROLE in "${ROLES[@]}";
    do
      echo "✨ ${PRINT_ROLE}"
    done

    echo -n "Insira a lista de usuarios separado por espaço "
    read GCP_USERS
    GCP_USERS=($(echo $GCP_USERS))

    for USER_EMAIL in "${GCP_USERS[@]}";
    do
        IS_SA="n"

        if echo "${USER_EMAIL}" | grep -qE "wppmediaservices|cherry|fbiz";
        then
          echo "$USER_EMAIL is a user"
        else;
          echo -n "is SA [$USER_EMAIL] ? [Y/N] "
          read IS_SA
        fi

        ORIGINAL_EMAIL="${USER_EMAIL}"
        
        if [[ $IS_SA = "Y" || $IS_SA = "y" ]];
        then
          USER_EMAIL="serviceAccount:${USER_EMAIL}"
        else
          USER_EMAIL="user:${USER_EMAIL}"
        fi

        for PROJECT_ID in $PROJECTS;
        do
          echo ""
          echo "---------------- [$PROJECT_ID] -----------------"
          for ROLE in $ROLES;
          do

            gcloud projects add-iam-policy-binding $PROJECT_ID --member="${USER_EMAIL}" --role=$ROLE -q --condition=None &>/dev/null

            if [ $? -eq 0 ]; then
              echo "Usuario [$ORIGINAL_EMAIL] adicionado [$ROLE] 🌞"
            else
              echo "Erro [$ORIGINAL_EMAIL] para role [$ROLE] 🚩"
            fi

          done
        done

    done

}


function appsflyer_url {


  current_dir=$(pwd)
  cd $HOME/terminal/terminal_python/appsflyer

  result=$(python parse_report.py $@)

  if [[ $? == 0 ]]; then
    echo $result | jq
  else
    echo $result
  fi

  cd $current_dir


}


function gce_connect {

    project=$(gcloud projects list --format="value(projectId)" | fzf --tmux 90%)
    gcloud compute ssh $(gcloud compute instances list  --project=$project --filter="status:RUNNING" --format="value(name)" | fzf --tmux 90%) --project $project
}

function cloudfunction_collectionids {


  current_dir=$(pwd)
  cd $HOME/terminal/terminal_python/cloudfunction

  project=$(gcloud projects list --format="value(projectId)" --filter="NOT projectId ~ datarepository" | fzf --tmux 90% )

  result=$(python list_collectionid.py $project)

  if [[ $? == 0 ]]; then
    echo $result | jq
  else
    echo $result
  fi

  cd $current_dir


}


function gcp_auth {

  gcloud auth revoke --all

  if [[ "$#" != "0" ]]; then

      gcloud auth login --project $1 --no-launch-browser
      gcloud auth application-default login --project $1 --no-launch-browser --scopes="https://www.googleapis.com/auth/drive,https://www.googleapis.com/auth/cloud-platform"

  else
      gcloud auth login
      gcloud auth application-default login --scopes="https://www.googleapis.com/auth/drive,https://www.googleapis.com/auth/cloud-platform"
  fi

  clear
  gcloud config list

}


function gcp_change_project {
  gcloud config set project $1 --quiet 2>/dev/null
  gcloud auth application-default set-quota-project $1 --quiet 2>/dev/null
  clear

}


function kms_decrypt {
  work_time
  current_dir=$(pwd)
  cd $HOME/terminal/terminal_python/kms_script

  for i in "$@" ; do
    if [[ $i == "-h" ]] ; then
        python3 decrypt.py -h
        break
    fi
  done

  result=$(python3 decrypt.py $@)
  cd $current_dir

}


function kms_encrypt {
  work_time
  current_dir=$(pwd)
  cd $HOME/terminal/terminal_python/kms_script

  for i in "$@" ; do
    if [[ $i == "-h" ]] ; then
        python3 decrypt.py -h
        break
    fi
  done

  result=$(python3 encrypt.py $@)
  cd $current_dir

}

function firestore_get_document {
  work_time
  current_dir=$(pwd)
  cd $HOME/terminal/terminal_python/firestore_script
  result=$(python3 getDocument.py $@)

  last_execution=$?

  if [[ $last_execution -eq 0 && $(echo $result) =~ "\{" ]]; then
      echo $result | jq
  else

    echo $result

  fi;

  cd $current_dir



}

function run_report_v2 {

  current_dir=$(pwd)
  cd $HOME/terminal/terminal_python

  if [[ "$#" != "0" ]]; then

      PROJECTS=($1)

  else
    PROJECTS=($(gcloud projects list --format="value(projectId)" --filter="NOT projectId ~ datarepository" | fzf --tmux 90% -m --prompt="Project> "))
  fi

  for PROJECT_ID in "${PROJECTS[@]}";
  do
    for API in $(python $HOME/terminal/terminal_python/firestore_script/search_apis.py "${PROJECT_ID}" | fzf --tmux -m --prompt="APIs for project [${PROJECT_ID}]> ");
    do

      for CLIENT in $(python "${HOME}/terminal/terminal_python/firestore_script/search_clients.py" "${PROJECT_ID}" | fzf --tmux -m --prompt="Clients for project [${PROJECT_ID}]> ");
      do

        REPORTS=($(python "${HOME}/terminal/terminal_python/firestore_script/search_report.py" "${PROJECT_ID}" "${CLIENT}" "${API}" | fzf --tmux -m --prompt="[${PROJECT_ID}] Reports for [${CLIENT} - ${API}]> "))
        REPORTS=$(IFS=, ; echo "${REPORTS[*]}")
        python $HOME/terminal/terminal_python/run_report_v2.py "${PROJECT_ID}" "${CLIENT}" "${API}" "${REPORTS}"
      done
      

    done

      for PAYLOAD_FILE in /tmp/run_report_v2*.json;
      do
        gcloud pubsub topics publish magrathea-queue-manager --project=$PROJECT_ID  --message="$(cat "${PAYLOAD_FILE}" | jq -c)"
        jq '.' "${PAYLOAD_FILE}"
        rm "${PAYLOAD_FILE}"
      done

  done

  cd "${current_dir}"


}



function run_report {
  work_time
  current_dir=$(pwd)
  cd $HOME/terminal/terminal_python


  if [[ "$#" != "0" ]]; then

      project=$(echo $1)
      python run_report.py $1

  else
      project=$(gcloud projects list --format="value(projectId)" --filter="NOT projectId ~ datarepository" | fzf --tmux 90% )
      python run_report.py $project
  fi



  pubsub_payload=$(cat report_tmp.json)

  if [[ $? == 0 || $? -eq "0" ]];then

    echo $project
    echo $pubsub_payload

    gcloud pubsub topics publish magrathea-queue-manager --project=$project  --message="$(cat report_tmp.json | jq -c)"
    rm report_tmp.json

  fi

  cd $current_dir

}


function datasink_transfers {

  figlet datasink -f slant
  work_time
  current_dir=$(pwd)
  cd $HOME/terminal/terminal_python/bq

  if [[ $# -eq 0 ]]; then
      cd querys
  else
      project_selected=$(gcloud projects list --format="value(PROJECT_ID)" --filter="parent.id:449413397360 OR parent.id:57669729297 OR parent.id:942946519066" | fzf --tmux 90%)
      rm -rf querys
      bq ls --transfer_config --transfer_location=US --format=prettyjson --project_id=$project_selected  --max_rows_per_request=1000 | jq -c '.[]' > querys.json
      mkdir querys
      python parse.py


    if [[ "$*" == *"-ddl"* ]]
    then

      echo "Updating DDL Information"
      for query in $(ls querys);
      do
          table_name=$(echo $query  | sed -r 's/\.sql//g')
          echo "* $table_name"
          result=$(bq show --format=prettyjson --project_id=$project_selected $table_name | jq '.schema.fields.[].name')
          echo "\n/*\n \
          DDL TABLE \n \
          $result \
          \n*/" >> querys/$query
      done

    fi


      cd querys
  fi

  oo
  cd $current_dir

}

function datasink_contains {

  figlet datasink -f slant
  work_time
  current_dir=$(pwd)
  cd $HOME/terminal/terminal_python/bq
  echo "Searching Argument : $1"

  if [[ -d $HOME/terminal/terminal_python/bq/querys && -n "$(ls -A $HOME/terminal/terminal_python/bq/querys)" && "$*" != *"-u"* ]]; then
    echo "==========================="
  else
      echo "Populating with new Information..."
      project_selected=$(gcloud projects list --format="value(PROJECT_ID)" --filter="parent.id:449413397360 OR parent.id:57669729297 OR parent.id:942946519066" | fzf --tmux 90%)
      rm -rf querys
      bq ls --transfer_config --transfer_location=US --format=prettyjson --project_id=$project_selected --max_rows_per_request=1000 | jq -c '.[]' > querys.json
      mkdir querys
      python parse.py

    if [[ "$*" == *"-ddl"* ]]
    then

      echo "Updating DDL Information"
      for query in $(ls querys);
      do
          table_name=$(echo $query  | sed -r 's/\.sql//g')
          echo "* $table_name"
          result=$(bq show --format=prettyjson --project_id=$project_selected $table_name | jq '.schema.fields.[].name')
          echo "\n/*\n \
          DDL TABLE \n \
          $result \
          \n*/" >> querys/$query
      done

    fi

      echo "==========================="
  fi

  cd $HOME/terminal/terminal_python/bq/querys
  rg . --no-ignore-vcs | grep "$1" | sed  -r 's/([0-9A-z\-_\.]+):.*/\1/g' | sed -r 's/^([0-9A-z_\-]+\.)([0-9A-z\-_]+).sql/\2/g' | xargs -n1 | sort -u
  echo "==========================="
  cd $current_dir

}


function magrathea_start {

    CLEAR="false"
    BUILD="false"
    START="false"
    APPEND="false"

    for arg in $@
    do
      case $arg in

            "-b")
                BUILD="true"
              ;;
            "-a")
                APPEND="true"
              ;;

            "-h")
                echo "
                  -b : Build magrathea with new repositories
                  -a : Append new repositories to magrathea

                  Usage
                  magrathea_start -b will build magrathea with new repositories
                  magrathea_start -a will append new repositories to magrathea
                  "
                  return 0
              ;;

        esac
    done


    CURRENT_DIR=$(pwd)
    MAGRATHEA_FOLDER="$WORK/github/magrathea"
    MAGRATHEA_REPOSITORIES_PATH="$MAGRATHEA_FOLDER/repositories.txt"
    cd $MAGRATHEA_FOLDER

    if [[ $BUILD == "false" ]];
    then
        echo "::::: BUILDING MAGRATHEA WITHOUT UPDATING REPOSITORIES :::::"
        docker compose up
        cd $CURRENT_DIR
        exit 1
    fi


    already=$(cat $MAGRATHEA_REPOSITORIES_PATH)


    if [[ $APPEND == "false" ]];
    then
        rm $MAGRATHEA_REPOSITORIES_PATH
    fi

    repository_name=$(gh repo list VMLYR --json name -L 1000 -q '.[] | .name' | fzf --tmux 90% -m)

    FIRST="true"
    for git_repository in $(echo $repository_name);
    do

        if [[ $APPEND == "true"  && $(echo $already | grep $git_repository | wc -l ) -eq 1 ]];
        then
            continue
        fi

        if [[ $APPEND == "true"  && $FIRST="true" ]];
        then
            echo -e "\n" >> $MAGRATHEA_REPOSITORIES_PATH
            FIRST="false"
        fi

        branch=$(gh api /repos/VMLYR/$git_repository/branches --jq '.[].name' | fzf --prompt="Branch for Repository $git_repository: " --tmux )

        if [[ -z $branch ]];
        then
            branch="main"
        fi

        echo "$git_repository:$branch" >> $MAGRATHEA_REPOSITORIES_PATH
    done

    python create_docker_files.py
    echo "::::: BUILDING MAGRATHEA WITH NEW REPOSITORIES :::::"
    docker compose up
    #docker compose up --force-recreate

    cd $CURRENT_DIR

}

function find_googleapis {
    CURRENT_DIR=$(pwd)
    DISCOVERY_URL="https://discovery.googleapis.com/discovery/v1/apis"
    SCOPE_PATH="/tmp/scopes"
    mkdir -p "${SCOPE_PATH}"
    for line in $(curl -s "$DISCOVERY_URL" | jq -c '.items[] | select(.preferred) | {name: .name , description: .description, doc : .documentationLink, title: .title} |@base64');
    do
        row=$(echo "$line" | base64 -di)
        

        name=$(echo "${row}" | jq  -r ".name")
        title=$(echo "${row}" | jq  -r ".title")
        description=$(echo "${row}" | jq -r ".description")
        doc=$(echo "${row}" | jq -r ".doc")
        echo """
# ${title}

    * resource : ${name}

## Description

${description}

scope url : ${doc}

        """ > "${SCOPE_PATH}/${name}.md" 
    done
    cd "${SCOPE_PATH}"
    nvim 
    cd "${CURRENT_DIR}"


}

function gcp_function_copy_envs {

  project_id=$(gcloud projects list --format="value(projectId)" | fzf --tmux );
  function_name=$(gcloud functions list --format="value(name)" --project "${project_id}" | fzf --tmux );
  gcloud functions describe "${function_name}" --project="${project_id}" --format=json | jq  ".serviceConfig.environmentVariables" > gcp_env.json

  echo '''
import os
import json

with open("gcp_env.json", "r", encoding="utf-8") as fp:
    envs = json.load(fp)
for env_name,env_value in envs.items():
    os.environ[env_name]=env_value

if "LOCAL_EMULATION" in os.environ:
    del os.environ["LOCAL_EMULATION"]

  ''' | clip


}



