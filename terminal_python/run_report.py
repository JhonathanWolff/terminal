import re
import json
import os
import sys
import subprocess
import firestore_script.ListCollection as firestore_list_collection
import datetime


GRANULARITY =[
    "day",
    "week",
    "month",
    "year",
    "aggregated",
    "hour"
]

TRUNCATE_PERIOD = {
    "googleanalytics4":"day"
}

def run(project:str):

    clientes = firestore_list_collection.list_collection("clients",project)
    cliente = get_fzf(clientes)

    with open("apis_configs/definitions.json","r",encoding="utf8") as f:
        apis = json.load(f)

    struct_apis = firestore_list_collection.list_collection("endpoint_struct",project,True)

    api_names = "\n".join([a for a in struct_apis])
    api_selecionada = get_fzf(api_names)

    if api_selecionada not in apis:
        sys.stdout.write("Api nao configurada " + api_selecionada)
        exit(1)


    start = input("Date Start : ").strip()
    end = input("Date end : ").strip()
    date_validation = r"\d{4}-\d{2}-\d{2}"
    format_date = "%Y-%m-%d"

    if re.match(r"\d+$",start):
        start = (datetime.datetime.now() - datetime.timedelta(days=int(start))).strftime(format_date)

    if re.match(r"\d+$",end):
        end = (datetime.datetime.now() - datetime.timedelta(days=int(end))).strftime(format_date)

    if not re.match(date_validation,start) or not re.match(date_validation,end):
        sys.stdout.write("Date start ou date end incorreto\n")
        exit(1)


    if (datetime.datetime.strptime(start,format_date) > datetime.datetime.strptime(end,format_date)
        or
        datetime.datetime.strptime(start,format_date).date() > datetime.datetime.now().date()
        or
        datetime.datetime.strptime(end,format_date).date() > datetime.datetime.now().date()
        ):

        sys.stdout.write("Periodo invalido")
        exit(1)

    if TRUNCATE_PERIOD.get(api_selecionada):
        granularity_select = TRUNCATE_PERIOD.get(api_selecionada)
    else:
        granularity_select = get_fzf("\n".join(GRANULARITY))


    start += " 00:00:00"
    end += " 23:59:59"


    info_api = apis[api_selecionada]
    api_resource = info_api["resource"]
    collection_key = info_api["collection_id"]
    if isinstance(collection_key,list):
        collection_key = get_fzf("\n".join(collection_key))

    collection_path = f"clients/{cliente}/endpoints/{api_selecionada}/{collection_key}"

    firestore_ids = firestore_list_collection.list_collection(collection_path,project)
    if firestore_ids.replace("\n","").strip() == "":
        sys.stdout.write("Endpoint ainda nao configurado no firestore :(")
        exit(1)


    if firestore_ids.endswith("\n"):
        firestore_ids+="all"
    else:
        firestore_ids+="\nall"


    collection_id_select = get_fzf(firestore_ids)

    if collection_id_select == "all":
        collection_id_select = None


    report_name = input("Relatorio : ").strip()
    if report_name == "":
        report_name = None

    sys.stdout.write(f"""

projeto : {project}
cliente : {cliente}
api : {api_selecionada}
report : {report_name}
collection_id : {collection_id_select}
collection_key : {collection_key}
period  :
    start : {start}
    end : {end}
    granularity : {granularity_select}
    include_partial : true

          """)

    input("------ PRESS ANY TO CONTINUE ---")

    payload = build_payload(
        api=api_selecionada,
        client=cliente,
        date_start=start,
        date_end=end,
        granularity=granularity_select,
        report=report_name,
        collection_key=collection_key,
        collection_id=collection_id_select,
        resource=api_resource
    )

    with open("report_tmp.json","w") as f:
        f.write(payload)
    exit(0)



def build_payload(api,client,
                  date_start,
                  date_end,
                  granularity,
                  report,
                  collection_id,
                  collection_key,
                  resource):

    obj = {

    "client": client,
    "period": {
      "start": date_start,
      "end": date_end,
      "granularity": granularity,
      "include_partial": True
    },
    "endpoints":{},
    "update_cache": True
    }

    obj["endpoints"][api] = {}
    obj["endpoints"][api][resource] = {}

    if collection_id is None:
        if report is not None:
            obj["endpoints"][api][resource]['reports'] = {}
            obj["endpoints"][api][resource]['reports'][report] = {}

    else:
        obj["endpoints"][api][resource][collection_key] = {}
        obj["endpoints"][api][resource][collection_key][collection_id] = [report] if report  else []

    return json.dumps(obj)


def get_fzf(text):
    result = (subprocess.Popen(f'echo "{text}" | fzf --tmux', shell=True, stdout=subprocess.PIPE).
            stdout.read().decode("utf8").replace("\n","").strip())

    if result == None or result == "":
        sys.stdout.write("Entrada invalida :(")
        exit(1)

    return result


if __name__ == "__main__":

    # run("arezzo-magrathea-execution")
    args = sys.argv
    args = args[1:]

    run(args[0])
