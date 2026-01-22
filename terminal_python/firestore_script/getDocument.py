import os
import json
import sys
import logging

def get_document(path, project_id, decript=False):

    os.environ["FUNCTION_NAME"] = "shell_script"
    os.environ["GCP_PROJECT"] = project_id
    from magrathea.gcloud.sdks.firestore import Firestore
    logger = logging.getLogger()
    logger.propagate = False
    logger.disabled = True
    fb = Firestore(project_id=project_id)
    data = fb.get_document(path)

    if not decript:
        return json.dumps(data)


    from magrathea.gcloud.sdks.kms import CloudKMS

    kms = CloudKMS(project_id=project_id,
            location_id="us-central1",
            key_ring_id="symmetric_ring",
            key_id=project_id

             )

    return json.dumps(kms.decrypt_symmetric(data))


if __name__ == "__main__":

    args = sys.argv

    if "-h" in args:
        print(f"""
                Required input:
                  <Firestore_PATH> --project=<PROJECT_ID>

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
        if "-d" in args:
            decript = True

        for a in args:
            if "--project=" in a:
                project_id = a.split("--project=")[1]


    if project_id is None:
        sys.stdout.write("Missing project id")
        exit(1)


    sys.stdout.write(get_document(path,project_id,decript=decript))

    exit(0)