import sys
import json
from urllib.parse import unquote


SPLITED_VALUES = [
    "event_counter",
    "unique_users",
    "sales_in_usd",
    "activity_event_counter",
    "activity_sales_in_usd",
    "activity_average_unique_users"
]

def parse(url):
    url = unquote(url)
    url_param = url.split("?")[1].split("&")


    parsed_param = {}
    for param in url_param:
        if "from=" in param or "to=" in param or "master_api_type=" in param:
            continue

        param_type,values = param.split("=")
        values =values.split(",")
        parsed_param[param_type] = values

    if "timezone" in parsed_param:
        parsed_param["timezone"] = parsed_param["timezone"][0]


    if "currency" in parsed_param:
        parsed_param["currency"] = parsed_param["currency"][0]


    update_index = {}
    all_index = []
    for index,kpi in enumerate(parsed_param["kpis"]):
        for prefix in SPLITED_VALUES:
            if kpi.startswith(prefix):
                if prefix not in update_index:
                    update_index[prefix] = []

                update_index[prefix].append(kpi.split(prefix+"_")[1])
                all_index.append(index)


    copy_kpis = []
    for index, value in enumerate(parsed_param["kpis"]):
        if index in all_index:
            continue
        copy_kpis.append(value)

    parsed_param["kpis"] = copy_kpis

    if "currency" not in parsed_param:
        parsed_param["currency"] = "preferred"

    if "timezone" not in parsed_param:
        parsed_param["timezone"] = "preferred"

    for k,_ in update_index.items():
        parsed_param["kpis"].append({k: update_index[k]})


    sys.stdout.write(json.dumps(parsed_param))




if __name__ == "__main__":

    args = sys.argv


    if "-h" in args:
        print("""
                Required input:
                  "<url>"

                url must have double quotes because & operator

                optional_flags:
                 -h -> will display help

              """)
        exit(1)


    if len(args) <= 1:
        sys.stdout.write("Esta Faltando Parametro")
        exit(1)


    args = args[1:]
    input_url = args[0]

    parse(input_url)
    exit(0)