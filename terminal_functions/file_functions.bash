

function avro_open ()
{
    FILE_PATH="$(pwd)/$1"

    python3 -c "
import json
import sys, fastavro
with open('$FILE_PATH', 'rb') as f:
    for record in fastavro.reader(f):
        print(json.dumps(record))
"
}
