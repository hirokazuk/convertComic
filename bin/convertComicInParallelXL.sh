#!/bin/bash
cd $(dirname $0)

# sleep 5
# echo @@@ $@ @@@
# terminal-notifier -title "title" -message "F $@ F"  #-group "gg"
# sleep 10

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:/opt/local/bin:/opt/local/sbin:$PATH
source /Users/Shared/dotfiles/.bash_profile_additional_all.sh

UUIDSUM=$$ #$(uuidgen | cksum |cut -f 1 -d " ")
COPIED_ORIGINAL_DIRPATH=/Users/Shared/noBackup/convertComic/original
EXTRACTED_DIRPATH=/Users/Shared/noBackup/convertComic/extracted$UUIDSUM
ZIPED_DIRPATH=/Users/Shared/noBackup/convertComic/ziped
FILECOUNT=$#
FILENAMES=

IFS_BACKUP=$IFS
IFS=$'\n'

count=0
f=$1
#for f in "$@"
#do
count=$((++count))
if [[ -f "$f" ]]; then
	ORIGINAL_PATH=$(dirname "$f")
	ORIGINAL_FILENAME=$(basename "$f")

	FILENAMES+="${ORIGINAL_FILENAME},"
	FNAME_COUNT="${count}/${FILECOUNT} $$ ${ORIGINAL_FILENAME}"

	ZIP_FILE_PATH="${ZIPED_DIRPATH}/${ORIGINAL_FILENAME%.*}_ownfix.zip"
	if [[ ! -f "$ZIP_FILE_PATH" ]]; then

		if [[ ! -f "${COPIED_ORIGINAL_DIRPATH}/${ORIGINAL_FILENAME}" ]]; then
#			ISTRUE "`KV_FIND SILENT`" && terminal-notifier -title "${FNAME_COUNT}" -message "$(echo ●copy ○unar ○conv ○zip ○deploy ○finish)" -group "$$"
			cp "$f" "$COPIED_ORIGINAL_DIRPATH"
		fi

#		ISTRUE "`KV_FIND SILENT`" && terminal-notifier -title "${FNAME_COUNT}" -message "$(echo ○copy ●unar ○conv ○zip ○deploy ○finish)" -group "$$"
		unar -q -D -o $EXTRACTED_DIRPATH/ "${COPIED_ORIGINAL_DIRPATH}/${ORIGINAL_FILENAME}"

#		ISTRUE "`KV_FIND SILENT`" && terminal-notifier -title "${FNAME_COUNT}" -message "$(echo ○copy ○unar ●conv ○zip ○deploy ○finish)" -group "$$"
		cd "$EXTRACTED_DIRPATH"
		current_dirs=$(gfind -O3 "$(pwd)" -type d -not -name '.*' -not -name 'tmp')
		echo ${current_dirs}
		while read dir; do
			cd "${dir}"
			#    	nconvert -quiet -ratio -rtype lanczos -rflag decr -resize 0 1200  -out jpeg -q 80 -opthuff -overwrite -D  *.{jpg,png,jpeg}
			#    	magick mogrify -filter lanczos -resize x1200\>  -format jpg -quality 80 -strip -interlace JPEG *.{jpg,png,jpeg} ; rm *.{png,jpeg}
			#    	magick mogrify -limit thread 2  -define jpeg:block-smoothing -define jpeg:size=900x1200 -strip  -fuzz 5% -trim +repage -filter lanczos -thumbnail x1024\>  -format jpg -sampling-factor 4:2:0 -quality 80 -interlace JPEG *.{jpg,png,jpeg} ; rm *.{png,jpeg}
			#    	ts -n -f -L "@${FNAME_COUNT}$$@" magick mogrify -limit thread 2 -define jpeg:block-smoothing -define jpeg:size=768x1024 -strip -fuzz 5% -trim +repage -filter lanczos -thumbnail x1024\>  -format jpg -sampling-factor 4:2:0 -quality 80 -interlace JPEG *.{jpg,png,jpeg}
      rename -v 's/\.jpg/\.jpeg/' *.jpg
			OPEND_GLOB=$(echo *.{avif,jpg,png,jpeg,AVIF,JPG,PNG,JPEG})
			echo "@${OPEND_GLOB}@"
			if [[ "${OPEND_GLOB}" != "*.avif *.jpg *.png *.jpeg *.AVIF *.JPG *.PNG *.JPEG" ]]; then
				#ts -n -f -L "@${FNAME_COUNT}$$@" magick mogrify -limit thread 2 -define jpeg:block-smoothing -define jpeg:size=768x1024 -strip -fuzz 5% -trim +repage -filter lanczos -thumbnail x1024\>  -format jpg -sampling-factor 4:2:0 -quality 80 -interlace JPEG *.{avif,jpg,png,jpeg}
				magick mogrify -limit thread 2 -define jpeg:block-smoothing -define jpeg:size=768x1024 -strip -fuzz 5% -trim +repage -filter lanczos -thumbnail x1024\> -format JXL -sampling-factor 4:2:0 -quality 80 -interlace JPEG *.{avif,jpg,png,jpeg,AVIF,JPG,PNG,JPEG}
				#ts -n -f -L "@${FNAME_COUNT}$$@" magick mogrify -limit thread 2 -define jpeg:block-smoothing -define jpeg:size=768x1024 -strip -fuzz 5% -trim +repage -gravity center -extent %[fx:max\(%[width]*0.6,w\)]x%[fx:max\(%[height]*0.4,h\)] -filter lanczos -thumbnail x%[fx:1024*\(h/%[height]\>0.85?1.0:h/%[height]\)]\> -format jpg -sampling-factor 4:2:0 -quality 80 -interlace JPEG *.{avif,jpg,png,jpeg}
				## -limit thread 2 -define jpeg:block-smoothing -define jpeg:size=768x1024 -strip -fuzz 5% -trim +repage -gravity center -extent %[fx:max\(%[width]*0.6,w\)]x%[fx:max\(%[height]*0.4,h\)] -filter lanczos -thumbnail x%[fx:1024*\(h/%[height]\>0.85?1.0:h/%[height]\)]\> -format jpg -sampling-factor 4:2:0 -quality 80 -interlace JPEG
				##magick mogrify -limit thread 2 -define jpeg:block-smoothing -define jpeg:size=768x1024 -strip -crop 2x1@ \( +clone -flop \) -delete 1 -define trim:edges=east -fuzz 5% -append -trim -crop 1x2@   \( +clone -flop \) -delete 1 +append -fuzz 5% -trim +repage -filter lanczos -thumbnail x1024\>  -format jpg -sampling-factor 4:2:0 -quality 80 -interlace JPEG *.{avif,jpg,png,jpeg,AVIF,JPG,PNG,JPEG}
				rm *.{png,jpeg,avif,PNG,JPEG,AVIF} *.{jpg~,png~,jpeg~,avif~,JPG~,PNG~,JPEG~,AVIF~}
			else
				echo not exists in $(pwd)
			fi

		done \
			< <(echo "$current_dirs")

		cd "$EXTRACTED_DIRPATH"
#		ISTRUE "`KV_FIND SILENT`" && terminal-notifier -title "${FNAME_COUNT}" -message "$(echo ○copy ○unar ○conv ●zip ○deploy ○finish)" -group "$$"
		zip -q -9 -r "${ZIP_FILE_PATH}" ./
	fi

	BACKUPED_UTIME=$(stat -f "%m" "$ORIGINAL_PATH")
	BACKUPED_DTIME=$(date -r $BACKUPED_UTIME +"%Y-%m-%dT%H:%M:%S")
#	ISTRUE "`KV_FIND SILENT`" && terminal-notifier -title "${FNAME_COUNT}" -message "$(echo ○copy ○unar ○conv ○zip ●deploy ○finish)" -group "$$"
	#BACKUP_TIMESTAMP "$ORIGINAL_PATH"
	xattr -w magick "fuzz=5%,trim,thumbnail=x1024,sampling-factor=4:2:0,quolity=80,interlace=JPEG" ${ZIP_FILE_PATH}
	cp "${ZIP_FILE_PATH}" "$ORIGINAL_PATH"
	touch -r "${ORIGINAL_PATH}/${ORIGINAL_FILENAME}" "${ORIGINAL_PATH}/${ORIGINAL_FILENAME%.*}_ownfix.zip"
	touch -d "$BACKUPED_DTIME" "$ORIGINAL_PATH"

	rm -rf "$EXTRACTED_DIRPATH"
	#rm -rf "$EXTRACTED_DIRPATH"
	#mkdir "$EXTRACTED_DIRPATH"

#	ISTRUE "`KV_FIND SILENT`" && terminal-notifier -title "${FNAME_COUNT}" -message "$(○copy ○unar ○conv ○zip ○deploy ●finish)" -group "$$"

fi
#done
#wait
#ISTRUE "`KV_FIND SILENT`" && terminal-notifier -title "完了(${SECONDS}sec) ${count}/${FILECOUNT} $$" -message "$FILENAMES" -group "$$"

IFS=$IFS_BACKUP
