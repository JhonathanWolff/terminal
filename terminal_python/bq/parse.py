import re
import json


with open("querys.json","r") as f:
    lines = [ json.loads(l) for l in f]


for line in lines:
    if  not re.match(r"^\d+",line["displayName"]):
        continue

    with open("querys/" + line["destinationDatasetId"] +"." + line["displayName"]+".sql","w") as f:
        f.write(line["params"]["query"])