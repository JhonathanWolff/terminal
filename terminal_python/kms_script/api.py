


def get_api(project_id):

    region="us-central1"
    if project_id == "tegrainc-magrathea-execution":
        region="southamerica-east1"

    from magrathea.gcloud.sdks.kms import CloudKMS
    return CloudKMS(project_id=project_id,
            location_id=region,
            key_ring_id="symmetric_ring",
            key_id=project_id

             )
