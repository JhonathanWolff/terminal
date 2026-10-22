#@ Files


#: Imprime registros de um arquivo avro como JSON: avro_open <arquivo>
function avro_open ()
{
    FILE_PATH="$(pwd)/$1"

    python3 -c "
import json
import sys, fastavro
with open('$FILE_PATH', 'rb') as f:
    for record in fastavro.reader(f):
        print(json.dumps(record))
"
}

#: Converte CRLF para LF em todos os arquivos (dos2unix)
function crl_to_lf {
    fd . -t f | xargs dos2unix
}

#: Conta frequencia de palavras de um arquivo: count_word <arquivo>
function count_word {
    tr -s '[:space:]' '\n' < "$1" | sort | uniq -c | sort -nr
}
