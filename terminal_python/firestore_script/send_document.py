import os
import json
import sys
import logging
from google.cloud import firestore


def send_document(fpath, path, project_id):

    logger = logging.getLogger()
    logger.propagate = False
    logger.disabled = True
    fb = firestore.Client(project=project_id)

    with open(path,"r") as f:
        data =json.load(f)

    if not data:
        return False


    data = fb.document(fpath).set(data)
    return True


if __name__ == "__main__":

    args = sys.argv

    if "-h" in args:
        print(f"""
                Required input:
                  <Firestore_PATH> --project=<PROJECT_ID> --file=$(pwd)/to_file.json

                optional_flags:
                 -h -> will display help
                 -d -> will decript

              """)
        exit(0)


    if len(args) <= 1:
        sys.stdout.write(f"Esta Faltando Parametro")
        exit(1)

    args = args[1:]

    path = args[0]

    if "/" not in path:
        sys.stdout.write("Firestore path invalido")
        exit(1)

    decript = False
    project_id = None
    if len(args) > 1:

        for a in args:
            if "--project=" in a:
                project_id = a.split("--project=")[1].split(" ")[0]

            if "--file=" in a:
                localpath = a.split("--file=")[1].split(" ")[0]


    if project_id is None:
        sys.stdout.write("Missing project id")
        exit(1)

    send_document(path=localpath,project_id=project_id,fpath=path)
    exit(0)
