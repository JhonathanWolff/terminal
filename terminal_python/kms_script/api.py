


def get_api(project_id):

    from magrathea.gcloud.sdks.kms import CloudKMS
    return CloudKMS(project_id=project_id,
            location_id="us-central1",
            key_ring_id="symmetric_ring",
            key_id=project_id

             )