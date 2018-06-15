#!/bin/bash
set -eu

function create_timestamp {
  timestamp="$(date +%Y-%m-%dT%H:%M:%S)"
}

function create_tempdir {
  tempdir="$(mktemp --directory -p "${temppath}")"
}

function remove_tempdir {
  rm -rf "${tempdir}"
}

function set_filename {
  filename="${timestamp}-${database}.gz"
}

function compress_data {
  cd "${tempdir}"
  tar --create --gzip --force-local --file "${filename}" "${database}"
}

function decompress_data {
  cd "${tempdir}"
  tar --extract --gzip --file "${filename}"
}

function dump_mongo {
  IFS=',' read -r -a collections <<< \
          "$(mongo --quiet --eval 'rs.slaveOk(); db.getCollectionNames();' "localhost/$database")"

  for collection in "${collections[@]}"
  do  

    mongodump \
      --db "${database}" \
      --collection "${collection}" \
      --out "${tempdir}"

  done
}

function restore_mongo {

    mongorestore --drop \
      --db "${database}" \
      "${tempdir}"

}

function push_s3 {
  aws s3 cp "${tempdir}/${filename}" "s3://${url}/${path}/${filename}" --sse AES256
}

function pull_s3 {
  aws s3 cp "s3://${url}/${path}/${filename}" "${tempdir}/${filename}" --sse AES256
}

function get_timestamp_s3 {
  timestamp="$(aws s3 ls "s3://${url}/${path}/" \
  | grep "-${database}" | tail -1 \
  | grep -o '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}')"
}

usage() {
  echo "help text"
  exit 0
}

while getopts "f:a:D:S:T:d:u:p:t:h" opt
do
  case "$opt" in
    f) configfile="$OPTARG";
       # shellcheck disable=SC1090
       source "${configfile}" ;;
    a) action="$OPTARG" ;;
    D) dbms="$OPTARG" ;;
    S) storagebackend="$OPTARG" ;;
    T) temppath="$OPTARG" ;;
    d) database="$OPTARG" ;;
    u) url="$OPTARG" ;;
    p) path="$OPTARG" ;;
    t) timestamp="$OPTARG" ;;
    *) usage ;;
  esac
done

: "${action?"Not specified (pass -a option)"}"
: "${dbms?"Not specified (pass -D option)"}"
: "${storagebackend?"Not specified (pass -S option)"}"
: "${temppath?"Not specified (pass -T option)"}"
: "${database?"Not specified (pass -d option)"}"
: "${url?"Not specified (pass -u option)"}"
: "${path?"Not specified (pass -p option)"}"

case ${action} in
  push) 
    create_tempdir
    create_timestamp
    set_filename
    "dump_${dbms}"
    compress_data
    "push_${storagebackend}"
    remove_tempdir
    exit
    ;;
  pull)
    create_tempdir
    "get_timestamp_${storagebackend}"
    set_filename
    "pull_${storagebackend}"
    decompress_data
    "restore_${dbms}"
    remove_tempdir
    exit
    ;;
esac
