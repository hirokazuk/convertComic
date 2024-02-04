cd `dirname $0`

echo 変換
find ./avif -name "*.avif" | while read -r fname
do
  echo "$fname"
  avifdec --no-strict --ignore-icc "$fname" "${fname%.*}.jpg" && rm "$fname"
done

echo 残avifファイル
find ./avif -name "*.avif" | while read -r fname
do
  echo "$fname"
done

#
# MOUNT_DIR=/Volumes/hiroiphone.local
# FILE_POSTFIX=
#
#
# TMP_DIR=/Users/Shared/noBackup
# GDRIVE_COMIC_DIR=/Volumes/GoogleDrive/マイドライブ/comics
#
#
# echo "getDirs"
# current_dirs=`gfind -O3 "$(pwd)"  -type d -not -name '.*' -not -name 'tmp'`
# echo "file_count"
# while read dir; do
#     #echo @@@"${dir}"
#     cd "${dir}"
#     pwd
#     #ls *.{png,jpeg,jpg}
#     nconvert -ratio -rtype lanczos -rflag decr -resize 800 1200  -out jpeg -q 80 -opthuff -overwrite -D  *.{jpg,png,jpeg}
# done < <(echo "$current_dirs") # | sort -r > ${TMP_DIR}/comicShare_fc_d${FILE_POSTFIX}.txt
#
# #read -p "Hit enter: "
