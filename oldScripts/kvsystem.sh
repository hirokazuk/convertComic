cd `dirname $0`

KV_REPOSITORY_DIR="/Users/Shared/noBackup/convertComic/名称未設定フォルダ"

function KV_ALL()  {
  csvq  -r "${KV_REPOSITORY_DIR}" "SELECT key,value FROM KEYVALUE"
}

function KV_CLEAR()  {
  csvq -N -a -f "FIXED" -r "${KV_REPOSITORY_DIR}" "DELETE FROM KEYVALUE"
  csvq -N -a -f "FIXED" -r "${KV_REPOSITORY_DIR}" "INSERT INTO KEYVALUE (KEY,VALUE) VALUES ('TESTKEY','TESTVALUE')"
}

function KV_FIND()  {
  if [ -z "$1" ]; then
    echo "no args" >&2
    return 1
  fi
  RESULT=$(csvq -N -a -f "FIXED" -r "${KV_REPOSITORY_DIR}" "SELECT VALUE FROM KEYVALUE WHERE KEY = '$1'")
  echo ${RESULT}
  if [ -z "${RESULT}" ]; then
    return 1
  else
    return 0
  fi
}

function KV_DELETE()  {
  if [ -z "$1" ]; then
    echo "no args" >&2
    return 1
  fi
  csvq -N -a -f "FIXED" -r "${KV_REPOSITORY_DIR}" "DELETE FROM KEYVALUE WHERE KEY = '$1'"
}

function KV_EXISTS()  {
  if [ -z $(KV_FIND "$1") ]; then
    return 1
  else
    return 0
  fi
}

function KV_MERGE()  {
  if [ -z "$1" -o -z "$2" ]; then
    echo "no args" >&2
    return 1
  fi
  csvq  -r "${KV_REPOSITORY_DIR}" "REPLACE INTO KEYVALUE (KEY,VALUE)  USING (KEY) VALUES ('$1','$2')"
}
function KV_ADD()  {
  if [ -z "$1" -o -z "$2" ]; then
    echo "no args" >&2
    return 1
  fi
  csvq  -r "${KV_REPOSITORY_DIR}" "REPLACE INTO KEYVALUE (KEY,VALUE)  USING (KEY) VALUES ('$1','$2')"
}



echo -KV_ALL-
KV_ALL

echo -KV_CLEAR-
KV_CLEAR

echo -KV_ALL-
KV_ALL

echo -KV_ADD "AAA" "aaa"-
KV_ADD "AAA" "aaa"

echo -KV_ADD "BBB" "bbb"-
KV_ADD "BBB" "bbb"

echo -KV_ADD "CCC" "ccc"-
KV_ADD "CCC" "ccc"

echo -KV_ADD "BBB" "βββ"-
KV_ADD "BBB" "βββ"

echo -KV_DELETE "CCC"-
KV_DELETE "CCC"

echo -KV_ALL-
KV_ALL

echo -KV_FIND "AAA"-
KV_FIND "AAA"
echo -KV_FIND "ZZZ"-
KV_FIND "ZZZ"
