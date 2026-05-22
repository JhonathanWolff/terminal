import sys
from google.cloud import firestore
from concurrent.futures import ThreadPoolExecutor,as_completed


def __thread_account_level(db:firestore.Client,path:str):

    reports = []
    for account_report in db.collection(f"{path}").stream():
        reports.append(account_report.id)

    return reports



def check_account_level(db:firestore.Client,client_name:str,endpoint_name:str):

    pool = ThreadPoolExecutor(10)
    jobs = []
    reports = []
    for configs in db.document(f"clients/{client_name}/endpoints/{endpoint_name}").collections():

        if configs.id == "reports":
            continue

        for account_id in db.collection(f"clients/{client_name}/endpoints/{endpoint_name}/{configs.id}").stream():
            pool.submit(
                    __thread_account_level,
                    db,
                    f"clients/{client_name}/endpoints/{endpoint_name}/{configs.id}/{account_id.id}/reports"
                    )
            # for account_report in db.collection(f"clients/{client_name}/endpoints/{endpoint_name}/{configs.id}/{account_id.id}/reports").stream():
            #     reports.append(account_report.id)

    for job in jobs:
        reports+= job.result()

    return list(set(reports))


def check_client_level(db:firestore.Client,client_name:str,endpoint_name:str):

    reports = []
    for configs in db.document(f"clients/{client_name}/endpoints/{endpoint_name}").collections():

        if configs.id == "reports":
            for report_name in db.collection(f"clients/{client_name}/endpoints/{endpoint_name}/{configs.id}").stream():
                reports.append(report_name.id)
                continue

    return list(set(reports))


def check_endpointconfigs_level(db:firestore.Client,endpoint_name:str):

    reports = []
    for report in db.collection(f"endpoint_configs/{endpoint_name}/reports").stream():
        reports.append(report.id)


    return list(set(reports))

def check_struct_level(db:firestore.Client,endpoint_name:str):

    reports = []
    for report in db.collection(f"endpoint_struct/{endpoint_name}/reports").stream():
        reports.append(report.id)

    return list(set(reports))


if __name__ == "__main__":
    args = sys.argv[1:]
    project_id,client,endpoint=args


    db = firestore.Client(project_id)


    pool = ThreadPoolExecutor(10)
    futures = []

    futures.append(
        pool.submit(
            check_account_level,
            db,client,endpoint
        )
    )
    futures.append(
        pool.submit(
            check_client_level,
            db,client,endpoint
        )
    )
    futures.append(
        pool.submit(
            check_endpointconfigs_level,
            db,endpoint
        )
    )
    futures.append(
        pool.submit(
            check_struct_level,
            db,endpoint
        )
    )

    all_results = []
    for future in as_completed(futures):
        all_results += (future.result())

    all_results.append("all")
    all_results = list(set(all_results))
    print("\n".join(sorted(all_results)))

