#@ GCP
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


#: Run Cloud Build triggers across projects
#: Usage: cloudbuild_republish [branch]
#:   [branch]  optional, default main.
#: Picks projects (fzf multi) and, on the first one, the triggers; runs the same triggers in every project.
#: Region us-central1 (southamerica-east1 for tegrainc projects).
function cloudbuild_republish {

  REGION="us-central1"
  TRIGGERS=()

  BRANCH="main"
  if [ ! "$#" -eq 0 ];
  then
      BRANCH="$1"
  fi
  echo "Publishing on branch ${BRANCH}"

  for PROJECT_ID in $(gcloud projects list --format="value(projectId)" | fzf --tmux -m);
  do

    REGION="us-central1"
    if  echo "${PROJECT_ID}" | grep -q "tegrainc";
    then
        REGION="southamerica-east1"
    fi

    echo "${REGION}"
    if [[ -z "${TRIGGERS[@]}" ]]; then
      for TRIGGER_NAME in $(gcloud builds triggers list --region="$REGION" --project "${PROJECT_ID}" --format="value(name)" | fzf --tmux -m);
      do
        TRIGGERS+=("${TRIGGER_NAME}")
      done
    fi

    for EXECUTE_TRIGGER in "${TRIGGERS[@]}";
    do
      echo "${EXECUTE_TRIGGER} --> ${PROJECT_ID}"
      gcloud builds triggers run "${EXECUTE_TRIGGER}" --branch="${BRANCH}" --project="${PROJECT_ID}" --region="${REGION}" 1>/dev/null
    done

  done

}

#: Run Cloud Build triggers with _FORCE_BUILD=true
#: Usage: cloudbuild_publish_new [branch]
#:   [branch]  optional, default main.
#: Like cloudbuild_republish, but passes --substitutions=_FORCE_BUILD=true. Does not work for tegra projects.
function cloudbuild_publish_new {

  REGION="us-central1"
  TRIGGERS=()

  BRANCH="main"
  if [ ! "$#" -eq 0 ];
  then
      BRANCH="$1"
  fi
  echo "Publishing on branch ${BRANCH}"

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
      gcloud builds triggers run "${EXECUTE_TRIGGER}" --project="${PROJECT_ID}" --region="${REGION}" --substitutions="_FORCE_BUILD=true" --branch="${BRANCH}" 1>/dev/null
    done

  done

}



#: Authenticated POST to a Cloud Function with saved payloads
#: Usage: gcp_curl_post [-n <file>] [-r <region>] [-s]
#:   -n <file>    opens ~/.payloads/<file> in nvim (create/edit a payload)
#:   -r <region>  region (default us-central1)
#:   -s           picks the body of a Cloud Scheduler POST job (fzf, preview decodes base64 to json)
#: Then picks project, function (URL) and payloads from ~/.payloads (fzf multi), opens each in nvim and POSTs with an identity token.
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

#: ADC login impersonating a service account
#: Usage: gcp_impersonate
#: Picks project(s) and service account (fzf) and runs gcloud auth application-default login --impersonate-service-account.
function gcp_impersonate {

        for PROJECT in $(gcloud projects list --format="value(projectId)" | fzf --tmux );
        do
            SA=$(gcloud iam service-accounts list --project="${PROJECT}" --format="value(email)" | fzf --tmux)
            gcloud auth application-default login --impersonate-service-account="${SA}"
        done
}


#: Activate a service account from a key JSON
#: Usage: gcp_sa_sheets_credentials <file.json>
#:   <file.json>  required. SA key, relative to the current directory.
#: Revokes current auth and ADC and activates the SA (client_email from the JSON).
function gcp_sa_sheets_credentials {
  FILE=$1
  CURRENT_DIR=$(pwd)
  gcloud auth revoke
  gcloud auth application-default revoke
  gcloud auth activate-service-account  $( cat "${CURRENT_DIR}/${FILE}" | jq -r '.client_email' ) --key-file="${CURRENT_DIR}/${FILE}"
}

#: Add IAM roles to users/SAs across projects
#: Usage: iam_add [-u]
#:   -u  clears and rebuilds the roles cache (gcp_roles.json)
#: Picks projects and roles (fzf multi), asks for the users and whether they are service accounts.
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

        if echo "${USER_EMAIL}" | grep -qE "wppmediaservices|cherry|fbiz|wppmedia|wppcommerce";
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


#: Decode an AppsFlyer report URL
#: Usage: appsflyer_url "<url>"
#:   "<url>"  required, in double quotes (because of &). -h shows the script help.
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


#: SSH into a Compute Engine VM
#: Usage: gce_connect
#: Picks project and RUNNING instance (fzf) and runs gcloud compute ssh.
function gce_connect {

    project=$(gcloud projects list --format="value(projectId)" | fzf --tmux 90%)
    gcloud compute ssh $(gcloud compute instances list  --project=$project --filter="status:RUNNING" --format="value(name)" | fzf --tmux 90%) --project $project
}

#: List Cloud Function collection ids
#: Usage: cloudfunction_collectionids
#: Picks the project (fzf, excludes datarepository) and runs list_collectionid.py.
function cloudfunction_collectionids {


  current_dir=$(pwd)
  cd $HOME/terminal/terminal_python/cloudfunction

  project=$(gcloud projects list --format="value(projectId)" --filter="NOT projectId ~ datarepository" | fzf --tmux 90% )

  result=$(python list_collectionid.py $project)

  if [[ $? == 0 ]]; then
    echo "${result}"
  else
    echo $result
  fi

  cd $current_dir


}


#: Redo gcloud and ADC login
#: Usage: gcp_auth [project]
#:   [project]  optional. If given, runs gcloud auth login and application-default login for that project (--no-launch-browser on the first).
#: Always revokes all credentials first.
function gcp_auth {

  gcloud auth revoke --all

  if [[ "$#" != "0" ]]; then

      gcloud auth login --project $1 --no-launch-browser
      gcloud auth application-default login --project $1 #--no-launch-browser --scopes="https://www.googleapis.com/auth/drive,https://www.googleapis.com/auth/cloud-platform"

  else
      gcloud auth login
      gcloud auth application-default login #--scopes="https://www.googleapis.com/auth/drive,https://www.googleapis.com/auth/cloud-platform"
  fi

  clear
  gcloud config list

}


#: Switch the gcloud project and the ADC quota project
#: Usage: gcp_change_project <project>
#:   <project>  required. Clears the screen at the end.
function gcp_change_project {
  gcloud config set project $1 --quiet 2>/dev/null
  gcloud auth application-default set-quota-project $1 --quiet 2>/dev/null
  clear

}


#: Decrypt a file with KMS
#: Usage: kms_decrypt <file> --project=<PROJECT_ID> [-r]
#:   -r  replace the content of the original file
#:   -h  script help (decrypt.py)
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


#: Encrypt a file with KMS
#: Usage: kms_encrypt <file> --project=<PROJECT_ID> [-r]
#:   -r  replace the content of the original file
#:   -h  script help (encrypt.py)
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

  python3 encrypt.py $@
  cd $current_dir

}


#: Send a JSON file as a Firestore document
#: Usage: firestore_send_document <firestore_path>
#:   <firestore_path>  required. E.g. collection/document
#: Picks the file (fzf, relative to the current directory) and the project (fzf) and runs send_document.py.
function firestore_send_document {
  work_time
  current_dir=$(pwd)

  FNAME=$(fzf --tmux)
  FNAME="$(pwd)/${FNAME}"
  PROJECT=$(gcloud projects list --format="value(projectId)" | fzf --tmux)

  cd $HOME/terminal/terminal_python/firestore_script
  result=$(python3 send_document.py $1 --project="${PROJECT}" --file="${FNAME}")

  last_execution=$?

  if [[ $last_execution -eq 0 && $(echo $result) =~ "\{" ]]; then
      echo $result | jq
  else

    echo $result

  fi;

  cd $current_dir



}


#: Download a decrypted Firestore document into cred.json
#: Usage: credentials_get_document <firestore_path> --project=<PROJECT_ID>
#: Runs firestore_get_document with -d, writes cred.json and adds cred.json to .gitignore.
function credentials_get_document {
  work_time
  current_dir=$(pwd)

  firestore_get_document $@ -d > cred.json
  echo -e "\ncred.json" >> ".gitignore"


}



#: Read a Firestore document
#: Usage: firestore_get_document <firestore_path> --project=<PROJECT_ID> [-d]
#:   -d  decrypt the content
#:   -h  script help (getDocument.py)
function firestore_get_document {
  work_time
  current_dir=$(pwd)
  cd $HOME/terminal/terminal_python/firestore_script
  result=$(python3 getDocument.py $@)

  last_execution=$?

  if [[ $last_execution -eq 0 && $(echo $result) =~ "\{" ]]; then
      echo $result
  else

    echo $result

  fi;

  cd $current_dir



}

#: Trigger Magrathea reports via Pub/Sub
#: Usage: run_report_v2 [project]
#:   [project]  optional. Without it, picks projects (fzf multi, excludes datarepository).
#: For each project picks client/API/reports (fzf) and publishes to the magrathea-queue-manager topic.
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



#: Trigger a Magrathea report via run_report.py
#: Usage: run_report [project]
#:   [project]  optional. Without it, picks the project (fzf, excludes datarepository).
#: Generates report_tmp.json and publishes to the magrathea-queue-manager topic.
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




#: Export the env vars of a Cloud Function
#: Usage: gcp_function_copy_envs
#: Picks project, function and region (fzf) and writes the variables to gcp_env.json in the current directory.
function gcp_function_copy_envs {

  project_id=$(gcloud projects list --format="value(projectId)" | fzf --tmux );
  function_name=$(gcloud functions list --format="value(name)" --project "${project_id}" | fzf --tmux  | sed "s/-/_/g");
  selected_region=$(printf "%s\n" "${GCP_REGIONS[@]}"  | fzf)
  gcloud functions describe "${function_name}" --project="${project_id}" --format=json  --region="${selected_region}" | jq  ".serviceConfig.environmentVariables" > gcp_env.json

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

#: magrathea_package_tester container
#: Usage: magrathea_tester
#: Configures docker for Artifact Registry and runs the magrathea_package_tester image with the current directory mounted at /app.
function magrathea_tester {
    gcloud auth configure-docker us-central1-docker.pkg.dev &>/dev/null
    docker run -v .:/app -it --rm "us-central1-docker.pkg.dev/hitchhikers-magrathea/magrathea-cicd/magrathea_package_tester:latest" /bin/bash
}




#: Clone a Firestore tree
#: Usage: firestore_clone_tree --project=<PROJECT_ID> --path=<path> [--database=<db>]
#:   --database  optional, default (default)
#:   -h          script help (clone_tree.py)
function firestore_clone_tree {
  python3 $HOME/terminal/terminal_python/firestore_script/clone_tree.py "$@"
}
