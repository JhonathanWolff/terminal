
function check_gcp_status {


DATAFLOW_PROJECTS=(
  "arezzo-magrathea-execution"
  "arezzo-project"
  "volvo-datarepository"
  "tegrainc-magrathea-execution"

  )


clear
figlet "Status Check " -f slant
last_3days=$(date "+%Y-%m-%dT%H:%M:%SZ" -d "3 day ago")

gh api "notifications?since=$last_3days&all=true" > /tmp/github_status.json


echo "============= Github Notification =============="
cat /tmp/github_status.json | jq -r '[["unread", "title", "reason", "url", "update_at" ], (.[] | select( .reason != "ci_activity" ) | . | [ .unread, .subject.title , .reason , .subject.url, .updated_at ])] | .[] | @tsv' \
  | sed -r 's/SUCCEEDED|true/✅/g' | sed -r 's/FAILED|false/❌/g' | sed -r 's/Cancelled/❓/g' \
  |  column -s $'\t' -t -o " | " 
  


echo "============= Github Notification =============="

rm /tmp/github_status.json



echo " "
echo " "

current_date=$(date "+%Y-%m-%d" -d "1 day ago")

for PROJECT in "${DATAFLOW_PROJECTS[@]}";
do

  echo "================ 😺 Status $PROJECT 😺 ==============="

  DATAFLOW_RESULT=$(gcloud dataflow jobs list --quiet --verbosity none --project $PROJECT --limit 5 --format=json --filter="state!=Done" --created-after=$current_date 2>/dev/null)

  if jq -e '. | any' <<< "$DATAFLOW_RESULT" >/dev/null ;
  then

    echo " "
    echo "------------ Dataflow Status $PROJECT ------------"
    echo $DATAFLOW_RESULT | jq  -r "[[\"Job Name\", \"state\" ], ( .[] | [.name, .state]) ] | .[] | @tsv" | column -s $'\t' -t -o " | "   | sed -r 's/SUCCEEDED|true/✅/g' | sed -r 's/FAILED|false|Failed/❌/g' | sed -r 's/Cancelled/❓/g' | sed -r 's/Running/🏃/g'
    echo "------------ Dataflow Status $PROJECT ------------"
  fi


  TRANSFER_LOCATION="us"
  if [[ $PROJECT == "tegrainc-magrathea-execution" ]];
  then
    TRANSFER_LOCATION="southamerica-east1"
  fi


  echo " "
  echo "------ Transfer Status ------------------"

  bq ls --transfer_config --project_id=$PROJECT --transfer_location=$TRANSFER_LOCATION --format=json | jq  -r "[[ \"Query Name\", \"Status\" ], (.[] | select (.disabled | not ) | . | [.displayName, .state ] ) ] | .[] | @tsv" | column -s $'\t' -t -o " | "   | sed -r 's/SUCCEEDED|true/✅/g' | sed -r 's/FAILED|false/❌/g' | sed -r 's/Running/🏃/g' | sed -r 's/Cancelled/❓/g'

  echo "------ Transfer Status ------------------"

  echo " "


  echo " "
  echo " "

done


}
