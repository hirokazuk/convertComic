#!/bin/bash
cd $(dirname $0)

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/opt/local/bin:/opt/local/sbin:$PATH
source /Users/Shared/dotfiles/.bash_profile_additional_all.sh

UUIDSUM=$$ #$(uuidgen | cksum |cut -f 1 -d " ")
COPIED_ORIGINAL_DIRPATH=/Users/Shared/noBackup/convertComic/original
mkdir -p "${COPIED_ORIGINAL_DIRPATH}"
EXTRACTED_DIRPATH=/Users/Shared/noBackup/convertComic/extracted$UUIDSUM
CONVERTED_DIRPATH=/Users/Shared/noBackup/convertComic/converted
mkdir -p "${CONVERTED_DIRPATH}"
FILECOUNT=$#
FILENAMES=

IFS_BACKUP=$IFS
IFS=$'\n'

count=0
f=$1
count=$((++count))
if [[ -f "$f" ]]; then
	ORIGINAL_DIR_PATH=$(dirname "$f")
	ORIGINAL_FILENAME=$(basename "$f")

	FILENAMES+="${ORIGINAL_FILENAME},"
	FNAME_COUNT="${count}/${FILECOUNT} $$ ${ORIGINAL_FILENAME}"

	CONVERTED_FILE_PATH="${CONVERTED_DIRPATH}/${ORIGINAL_FILENAME%.*}_ownfix.zip"
	echo "$CONVERTED_FILE_PATH"
	if [[  -f "$CONVERTED_FILE_PATH" ]]; then
		rm -v "$CONVERTED_FILE_PATH"
	fi

		if [[ ! -f "${COPIED_ORIGINAL_DIRPATH}/${ORIGINAL_FILENAME}" ]]; then
			cp "$f" "$COPIED_ORIGINAL_DIRPATH"
		fi

		unar -q -D -o $EXTRACTED_DIRPATH/ "${COPIED_ORIGINAL_DIRPATH}/${ORIGINAL_FILENAME}"

		cd "$EXTRACTED_DIRPATH"



#jpgはjpegにリネームしておく（後で削除できるように）
		 gfind ./ -type f -iname "*.jpg" -print0 | \
		 	xargs -0 -I {} rename -v 's/\.jpg$/\.jpeg/i' {}
#変換
		 gfind ./ -type f -and \( -iname "*.avif" -or -iname "*.png"  -or -iname "*.jpeg" -or -iname "*.jpg" \) -print0 | \
		 	xargs -0 magick mogrify -verbose -limit thread 2 -define jxl:effort=9 -define jpeg:block-smoothing -define jpeg:size=768x1024 -strip -fuzz 5% -trim +repage -filter lanczos -thumbnail x1024\> -format JXL -sampling-factor 4:2:0 -quality 60 -interlace  JPEG
			MAGICK_OPTION_VERSION=20240106
#変換後にオリジナルを削除する  ※変換フォーマットがjpgなら [-or -iname "*.jpg"]ははずすように
     gfind ./ -type f -and \( -iname "*.avif" -or -iname "*.png"  -or -iname "*.jpeg" -or -iname "*.jpg" \) -print0 |  \
		 	xargs -0 -I {} rm -v {}


		cd "$EXTRACTED_DIRPATH"
		zip -v -q -9 -r "${CONVERTED_FILE_PATH}" ./  -x "*.DS_Store"


	BACKUPED_UTIME=$(stat -f "%m" "$ORIGINAL_DIR_PATH")
	BACKUPED_DTIME=$(date -r $BACKUPED_UTIME +"%Y-%m-%dT%H:%M:%S")
	xattr -w magick "${MAGICK_OPTION_VERSION}@magick mogrify -limit thread 2 -define jxl:effort=9 -define jpeg:block-smoothing -define jpeg:size=768x1024 -strip -fuzz 5% -trim +repage -filter lanczos -thumbnail x1024\> -format JXL -sampling-factor 4:2:0 -quality 60 -interlace  JPEG" ${CONVERTED_FILE_PATH}
	echo cp "${CONVERTED_FILE_PATH}" "$ORIGINAL_DIR_PATH"
	cp "${CONVERTED_FILE_PATH}" "$ORIGINAL_DIR_PATH"
	touch -r "${ORIGINAL_DIR_PATH}/${ORIGINAL_FILENAME}" "${ORIGINAL_DIR_PATH}/${ORIGINAL_FILENAME%.*}_ownfix.zip"
	touch -d "$BACKUPED_DTIME" "$ORIGINAL_DIR_PATH"

	rm -rf "$EXTRACTED_DIRPATH"
fi

IFS=$IFS_BACKUP