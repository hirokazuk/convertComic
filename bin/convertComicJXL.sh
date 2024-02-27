#!/usr/bin/env bash
# code: language=bash

# スクリプトの実体のあるディレクトリに移動
cd "$(dirname "$(readlink -f "$0")")" || exit

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/opt/local/bin:/opt/local/sbin:$PATH

SCRIPT_DIR_PATH="$(pwd)"

UUIDSUM=$$ #$(uuidgen | cksum |cut -f 1 -d " ")
COPIED_ORIGINAL_DIRPATH=${SCRIPT_DIR_PATH}/original
mkdir -p "${COPIED_ORIGINAL_DIRPATH}"
EXTRACTED_DIRPATH=${SCRIPT_DIR_PATH}/extracted$UUIDSUM
CONVERTED_DIRPATH=${SCRIPT_DIR_PATH}/converted
mkdir -p "${CONVERTED_DIRPATH}"
FILECOUNT=$#
FILENAMES=

IFS_BACKUP=$IFS
IFS=$'\n'

count=0
f=$1
count=$((++count))
if [[ -f "$f" ]]; then
	#ターゲットファイルのCC_*タグを削除してCC_PROCESSINGを付与
	tag --remove $(tag --list -N "$f"| tr ',' '\n' | grep '^CC_'| tr '\n' ',') "$f"
	tag --add CC_PROCESSING "$f"

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

		# 内部の圧縮ファイルを検索して解凍
		find "$EXTRACTED_DIRPATH" -type f -and \( -iname "*.zip" -or -iname "*.rar" \) | while read -r inner_archive; do
			echo "inner_archive:$inner_archive"
			inner_extracted_dir="$(dirname "$inner_archive")"
			echo "inner_extracted_dir:$inner_extracted_dir"
			cd "$inner_extracted_dir"
			unar -q -d -o "$inner_extracted_dir" "$inner_archive" && rm "$inner_archive"
		done
		# 内部の圧縮ファイルを検索して解凍
		find "$EXTRACTED_DIRPATH" -type f -and \( -iname "*.zip" -or -iname "*.rar" \) | while read -r inner_archive; do
			echo "inner_archive:$inner_archive"
			inner_extracted_dir="$(dirname "$inner_archive")"
			echo "inner_extracted_dir:$inner_extracted_dir"
			cd "$inner_extracted_dir"
			unar -q -d -o "$inner_extracted_dir" "$inner_archive" && rm "$inner_archive"
		done
		cd "$EXTRACTED_DIRPATH"



#jpgはjpegにリネームしておく（後で削除できるように）
		 gfind ./ -type f -iname "*.jpg" -print0 | \
		 	xargs -0 -I {} rename -v 's/\.jpg$/\.jpeg/i' {}
#変換
		 gfind ./ -type f -and \( -iname "*.avif" -or -iname "*.png"  -or -iname "*.jpeg" -or -iname "*.jpg" -or -iname "*.gif"  \) -print0 | \
		 	xargs -0 magick mogrify -verbose -limit thread 1 -define jxl:effort=5 -define jpeg:block-smoothing -define jpeg:size=768x1024 -strip -fuzz 5% -trim +repage -filter lanczos -thumbnail x1024\> -format JXL -sampling-factor 4:2:0 -quality 60 -interlace  JPEG
			MAGICK_OPTION_VERSION=20240107
#変換後にオリジナルを削除する  ※変換フォーマットがjpgなら [-or -iname "*.jpg"]ははずすように
     # gfind ./ -type f -and \( -iname "*.avif" -or -iname "*.png"  -or -iname "*.jpeg" -or -iname "*.jpg" \) -print0 |  \
		 # 	xargs -0 -I {} rm -v {} #rmの{}が変換されない（スペース入りのディレクトリが関係か）
			gfind ./ -type f -and \( -iname "*.avif" -or -iname "*.png"  -or -iname "*.jpeg" -or -iname "*.jpg" -or -iname "*.gif"  \)  -delete


		cd "$EXTRACTED_DIRPATH"
		zip -v -q -9 -r "${CONVERTED_FILE_PATH}" ./  -x "*.DS_Store"


	BACKUPED_UTIME=$(stat -f "%m" "$ORIGINAL_DIR_PATH")
	BACKUPED_DTIME=$(date -r $BACKUPED_UTIME +"%Y-%m-%dT%H:%M:%S")

	#ターゲットファイルのCC_*タグを削除してCC_CONVERTEDを付与
	tag --remove $(tag --list -N "$f"| tr ',' '\n' | grep '^CC_'| tr '\n' ',') "$f"
	tag --add CC_CONVERTED "$f"

	#変換済みファイルのCC_*タグを削除してCC_JXL_1を付与
	xattr -w magick "${MAGICK_OPTION_VERSION}@magick mogrify -verbose -limit thread 2 -define jxl:effort=5 -define jpeg:block-smoothing -define jpeg:size=768x1024 -strip -fuzz 5% -trim +repage -filter lanczos -thumbnail x1024\> -format JXL -sampling-factor 4:2:0 -quality 60 -interlace  JPEG" ${CONVERTED_FILE_PATH}
	tag --remove $(tag --list -N "${CONVERTED_FILE_PATH}"| tr ',' '\n' | grep '^CC_'| tr '\n' ',') "${CONVERTED_FILE_PATH}"
	tag --add CC_JXL_1 "${CONVERTED_FILE_PATH}"

	echo cp "${CONVERTED_FILE_PATH}" "$ORIGINAL_DIR_PATH"
	cp "${CONVERTED_FILE_PATH}" "$ORIGINAL_DIR_PATH"
	touch -r "${ORIGINAL_DIR_PATH}/${ORIGINAL_FILENAME}" "${ORIGINAL_DIR_PATH}/${ORIGINAL_FILENAME%.*}_ownfix.zip"
	touch -d "$BACKUPED_DTIME" "$ORIGINAL_DIR_PATH"

	rm -rf "$EXTRACTED_DIRPATH"
	rm "${CONVERTED_FILE_PATH}"
	rm "${COPIED_ORIGINAL_DIRPATH}/${ORIGINAL_FILENAME}"
fi

IFS=$IFS_BACKUP
