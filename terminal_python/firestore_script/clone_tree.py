import json
import os
import sys

from google.cloud import firestore

HELP = """
firestore_clone_tree

Required flags:
  --project=<PROJECT_ID>   projeto do GCP
  --path=<FIRESTORE_PATH>  caminho do firestore (colecao ou documento)

Optional flags:
  --database=<DATABASE>    padrao "(default)"
  --help                   exibe esta ajuda

Cria a pasta firestore_tree no diretorio atual replicando a estrutura:
pasta = colecao, arquivo json = documento, pasta com nome do documento = subcolecoes.
"""


def write_document(dest, snapshot):
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    data = snapshot.to_dict() if snapshot.exists else None
    with open(dest, "w") as f:
        json.dump(data or {}, f, indent=2, ensure_ascii=False, default=str)


def clone_document(doc_ref, dest_dir):
    # ponytail: get() em vez de stream() para tambem pegar documento fantasma
    snapshot = doc_ref.get()
    dest = os.path.join(dest_dir, f"{doc_ref.id}.json")
    print(f"documento: {doc_ref.path}{'' if snapshot.exists else ' (fantasma)'}")
    write_document(dest, snapshot)

    for collection in doc_ref.collections():
        clone_collection(collection, os.path.join(dest_dir, doc_ref.id))


def clone_collection(collection_ref, dest_dir):
    print(f"colecao: {collection_ref.id}")
    dest_dir = os.path.join(dest_dir, collection_ref.id)
    os.makedirs(dest_dir, exist_ok=True)

    for doc_ref in collection_ref.list_documents():
        clone_document(doc_ref, dest_dir)


def clone_tree(path, project_id, database):
    db = firestore.Client(project=project_id, database=database)
    parts = [p for p in path.strip("/").split("/") if p]
    root = os.path.join(os.getcwd(), "firestore_tree", *parts[:-1])

    if len(parts) % 2 == 0:
        clone_document(db.document(path), root)
    else:
        clone_collection(db.collection(path), root)


if __name__ == "__main__":
    args = sys.argv[1:]

    if "--help" in args or "-h" in args:
        print(HELP)
        exit(0)

    flags = dict(a.split("=", 1) for a in args if a.startswith("--") and "=" in a)
    project_id = flags.get("--project")
    path = flags.get("--path")
    database = flags.get("--database", "(default)")

    if not project_id:
        sys.stderr.write("Missing --project\n")
        exit(1)

    if not path:
        sys.stderr.write("Missing --path\n")
        exit(1)

    clone_tree(path, project_id, database)
    exit(0)
