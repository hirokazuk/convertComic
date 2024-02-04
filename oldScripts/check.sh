#!/bin/bash
cd $(dirname $0)

#!/bin/bash

# ディレクトリを指定
dir="/Volumes/comic/JDown"

# ファイル名の末尾が「_ownfix.zip」のファイルを取得
find "$dir" -name "*_ownfix.zip" | tee temp.txt

# 中間ファイルから処理
cat temp.txt | while read file; do

  # xattrを取得
  xattr_value=$(xattr -p magick "$file")

  # xattrが「20240107@」で始まらない場合
  if [[ "$xattr_value" != "20240107@"* ]]; then

    # ファイル名を表示
    echo "@@$file"
		tag --remove $(tag --list -N "${file}"| tr ',' '\n' | grep '^CC_'| tr '\n' ',') "${file}"
		tag --add CC_OLD "${file}"
	else
		tag --remove $(tag --list -N "${file}"| tr ',' '\n' | grep '^CC_'| tr '\n' ',') "${file}"
		tag --add CC_JXL_1 "${file}"
  fi
done
