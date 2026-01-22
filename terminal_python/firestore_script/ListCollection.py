
import os
import json
import sys
import logging

def list_collection(path, project_id,return_array=False):

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


