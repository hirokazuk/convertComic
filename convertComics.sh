#!/bin/bash
cd $(dirname $0)

#export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/opt/local/bin:/opt/local/sbin:$PATH
#source /Users/Shared/dotfiles/.bash_profile_additional_all.sh

# exec 1> >(ts|tee -a /Users/Shared/dotfiles/convertComics.log)
# exec 2> >(ts|tee -a /Users/Shared/dotfiles/convertComics.log)

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
  if [[ -f "$f" ]]; then
	dirpaths+=( $(dirname "$f") )
  fi
done

uniq_dirpaths=$( printf "%s\n" "${dirpaths[@]}" | sort -u )
for uniq_dirpath in ${uniq_dirpaths[@]}
do
  if [[ -d "$uniq_dirpath" ]]; then
	#echo "@uniq_dirpath@:$uniq_dirpath"
    BACKUP_TIMESTAMP "$uniq_dirpath"
  fi
done

pueued -d
pueue group add  cc
pueue parallel -g cc 2
for f in "$@"
do
  if [[ -f "$f" ]]; then
	TARGET_FILE_NAME=`basename "${f}"`
	TARGET_DIR_PATH=`dirname "${f}"`
	TARGET_DIR_NAME=`basename "${TARGET_DIR_PATH}"`
	pueue add -g cc -l "${TARGET_DIR_NAME}:${TARGET_FILE_NAME}" -- "./convertComicJXL.sh '${f}'"
  fi
done

IFS=$IFS_BACKUP
