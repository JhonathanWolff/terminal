import sys
from google.cloud import firestore

def search_apis(db:firestore.Client):

    reports = []
    for report in db.collection(f"endpoint_struct").stream():
        reports.append(report.id)

    return list(set(reports))


if __name__ == "__main__":
    
    args = sys.argv[1:]
    project_id=args[0]

    all_results =[]

    db = firestore.Client(project_id)
    print("\n".join(sorted(search_apis(db))))

