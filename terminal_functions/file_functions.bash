#@ Files


#: Imprime registros de um arquivo avro como JSON
#: Uso: avro_open <arquivo.avro>
#:   <arquivo.avro>  obrigatorio. Caminho relativo ao diretorio atual.
#: Um registro JSON por linha. Requer python3 com fastavro.
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

#: Converte CRLF para LF recursivamente
#: Uso: crl_to_lf
#: Roda dos2unix em todos os arquivos (fd -t f) a partir do diretorio atual. Altera os arquivos no lugar.
function crl_to_lf {
    fd . -t f | xargs dos2unix
}

#: Frequencia de palavras de um arquivo
#: Uso: count_word <arquivo>
#:   <arquivo>  obrigatorio. Saida: contagem + palavra, da mais para a menos frequente.
function count_word {
    tr -s '[:space:]' '\n' < "$1" | sort | uniq -c | sort -nr
}
