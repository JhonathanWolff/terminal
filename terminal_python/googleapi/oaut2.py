from hashlib import sha256
import json
from urllib.parse import unquote,quote_plus,quote

AUTH_URI="https://accounts.google.com/o/oauth2/auth"
SCOPES=[

]
while True:

    option:str=input("Insira o scope que deseja ou se nao digite y para sair: ").trim()

    if option.lower() == "y":
        break

    SCOPES.append(option)


CLIENT_ID=input("Insira o Client ID: ").strip()
CLIENT_SECRET=("Insira o Client Secret: ").strip()
STATE=sha256().hexdigest().replace("-","")

url = AUTH_URI
url += "?response_type=code"
url += f"&client_id={CLIENT_ID}"
url += f"&redirect_uri={quote('http://localhost')}"
url += f"&scope={'+'.join([quote(x) for x in SCOPES])}"
url += "&access_type=offline"
url += "&prompt=consent"
url += f"&state={STATE}"

print(url)

code = input("Insira o codigo de autorizacao: ").strip()


body = {
    "code": code,
    "client_id": CLIENT_ID,
    "client_secret": CLIENT_SECRET,
    "redirect_uri": 'http://localhost',
    "grant_type": "authorization_code",
    "state": STATE
}

import requests


ret = requests.post(url="https://accounts.google.com/o/oauth2/token", json=body)

print(json.dumps(ret.json(), indent=4))
