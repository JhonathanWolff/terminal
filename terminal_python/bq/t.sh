for query in $(ls querys);
do
    table_name=$(echo $query  | sed -r 's/\.sql//g')
    echo $table_name
    result=$(bq show --format=prettyjson --project_id=azul-datarepository azul_datawarehouse.01_azul_grouped_adobe | jq '.schema.fields.[].name')
    echo "\n/*\n \
    DDL TABLE \n \
    $result \
    \n*/" >> querys/$query

done
