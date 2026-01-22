
import os
import json
import sys
import logging
import api



def decript(project_id,file_path,replace=False):

    if not os.path.exists(file_path):
        sys.stdout.write("File does not exists")
        exit(1)

    with open(file_path,"r",encoding="utf8") as f:
        data = json.load(f)

    kms = api.get_api(project_id)
    data = kms.decrypt_symmetric(data)

    if not replace:
        paths = file_path.split("/")
        paths[-1] = paths[-1].split(".json")[0] +"_decrypt.json"
        file_path = "/".join(paths)

    with open(file_path,"w",encoding="utf8") as f:
        json.dump(data,f,indent=4)



if __name__ == "__main__":
    args = sys.argv

    if "-h" in args:

        print("""
                Required input:
                <Local FPath> --project=<PROJECT_ID>

                optional_flags:
                -h -> help
                -r -> will replace the content from original file

              """)
        exit(0)

    args = args[1:]

    if len(args) == 1:
        sys.stdout.write("Invalid command see help!")
        exit(1)

    replace = False
    project_id = None
    if len(args) > 1:
        if "-r" in args:
            replace = True

        for a in args:
            if "--project=" in a:
                project_id = a.split("--project=")[1]


    if project_id is None:
        sys.stdout.write("Missing project id")
        exit(1)


    os.environ["FUNCTION_NAME"] = "shell_script"
    os.environ["GCP_PROJECT"] = project_id
    decript(project_id,args[0],replace)
    exit(0)
