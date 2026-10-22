#@ Files


#: Print the records of an avro file as JSON
#: Usage: avro_open <file.avro>
#:   <file.avro>  required. Path relative to the current directory.
#: One JSON record per line. Requires python3 with fastavro.
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

#: Convert CRLF to LF recursively
#: Usage: crl_to_lf
#: Runs dos2unix on every file (fd -t f) from the current directory. Modifies files in place.
function crl_to_lf {
    fd . -t f | xargs dos2unix
}

#: Word frequency of a file
#: Usage: count_word <file>
#:   <file>  required. Output: count + word, most to least frequent.
function count_word {
    tr -s '[:space:]' '\n' < "$1" | sort | uniq -c | sort -nr
}
