import requests
import re
import json
import os
import sys
import subprocess
import datetime
import logging


def list_collection(path, project_id, return_array=False):

    os.environ["FUNCTION_NAME"] = "shell_script"
    os.environ["GCP_PROJECT"] = project_id
    from magrathea.gcloud.sdks.firestore import Firestore
    logger = logging.getLogger()
    logger.propagate = False
    logger.disabled = True
    fb = Firestore(project_id=project_id)
    data = fb.get_document_names_from_collection(path)
    if not return_array:
        return "\n".join(data)
    return data


def run(project):

    struct_apis = list_collection("endpoint_struct", project, True)
    api_names = "\n".join([a for a in struct_apis])
    api_selected = get_fzf(api_names)

    # resources = list_collection(f"endpoint_struct/{api_selected}/resources", project, True)

    resource = "list_collectionids"

    # if "list_collectionids" not in resources:
    #     sys.stdout.write("Resource nao configurado list_colelctionids nao encontrado")
    #     exit(1)

    users = list_collection(f"endpoint_configs/{api_selected}/users", project, True)
    user_selected = get_fzf("\n".join([a for a in users]))

    resp = do_request(project,api_selected,user_selected)

    sys.stdout.write(json.dumps(fix_strings(resp)))


def fix_strings(obj):
    """Fix strings with invalid backslash sequences"""
    if isinstance(obj, dict):
        return {k: fix_strings(v) for k, v in obj.items()}
    elif isinstance(obj, list):
        return [fix_strings(item) for item in obj]
    elif isinstance(obj, str):
        # Replace single backslashes with double backslashes
        # But only if not already escaped
        obj = obj.replace('\\', '\\\\')
        return obj
    return obj




def do_request(project,function,user_name):

    token = (subprocess.Popen('gcloud auth print-identity-token', shell=True, stdout=subprocess.PIPE).
              stdout.read().decode("utf8").replace("\n", "").strip())
    header = {
        "Authorization": f"Bearer {token}"
    }

    # gcloud functions list --project=arezzo-magrathea-execution --filter="name:awss3" --format="value(httpsTrigger.url)"


    url = (subprocess.Popen(f'gcloud functions list --project={project} --filter="name~{function}$" --format="value(url)"', shell=True, stdout=subprocess.PIPE).
              stdout.read().decode("utf8").replace("\n", "").strip())

    if not url:
        sys.stdout.write(f"Trigger not found for function {function}")
        exit(1)

    resp =requests.post(url=url, headers=header,data=json.dumps(
        {
            "resource": "list_collectionids",
            "user_name": user_name
        }
    ),timeout=540)

    return resp.json()


def get_fzf(text):
    result = (subprocess.Popen(f'echo "{text}" | fzf', shell=True, stdout=subprocess.PIPE).
              stdout.read().decode("utf8").replace("\n", "").strip())

    if result == None or result == "":
        sys.stdout.write("Entrada invalida :(")
        exit(1)

    return result


if __name__ == "__main__":
    args = sys.argv
    args = args[1:]
    run(args[0])
    # run("arezzo-magrathea-execution")
    exit(0)
