#!/usr/bin/env bash
# code: language=bash

# スクリプトの実体のあるディレクトリに移動
cd "$(dirname "$(readlink -f "$0")")" || exit

#export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/opt/local/bin:/opt/local/sbin:$PATH
#source /Users/Shared/dotfiles/.bash_profile_additional_all.sh
mkdir ./logs
exec 1> >(ts|tee -a ./logs/convertComics.log)
exec 2> >(ts|tee -a ./logs/convertComics.log)

# echo @@2:${@}
#
# for f in "$@"
# do
#   echo @2:${f}
# done


IFS_BACKUP=$IFS
IFS=$'\n'


dirpaths=()
for f in "$@"
do
  # if [[ -f "$f" ]]; then
	dirpaths+=( $(dirname "$f") )
  # fi
done

uniq_dirpaths=$( printf "%s\n" "${dirpaths[@]}" | sort -u )
for uniq_dirpath in ${uniq_dirpaths[@]}
do
  # if [[ -d "$uniq_dirpath" ]]; then
	  #echo "@uniq_dirpath@:$uniq_dirpath"
    BACKUP_TIMESTAMP "$uniq_dirpath"
  # fi
done

pueued -d
pueue group add  cc
pueue parallel -g cc 4
for f in "$@"
do
  if [[ -f "$f" ]]; then
  	TARGET_FILE_NAME=`basename "${f}"`
  	TARGET_DIR_PATH=`dirname "${f}"`
  	TARGET_DIR_NAME=`basename "${TARGET_DIR_PATH}"`

    tag --remove $(tag --list -N "$f"| tr ',' '\n' | grep '^CC_'| tr '\n' ',') "$f"
    tag --add CC_QUEUED "$f"
  	pueue add -g cc -l "${TARGET_DIR_NAME}:${TARGET_FILE_NAME}" -- "convertComicJXL.sh \"${f}\""
  fi
done

IFS=$IFS_BACKUP
