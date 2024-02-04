#!/bin/bash
cd $(dirname $0)

# 指定日時A（例: 2022-01-01 00:00:00）
specified_date_A="2024-01-20 00:00:00"

# 指定日時B（例: 2022-01-02 00:00:00）
specified_date_B="2025-01-01 00:00:00"

# 特定のディレクトリ(A)のパス
source_directory="/Volumes/comic/JDown"
#source_directory="/Users/Shared/noBackup/convertComic/wocopy/A"

# 別の指定ディレクトリ(B)のパス
destination_directory="/Volumes/comic/JDown_wo"
#destination_directory="/Users/Shared/noBackup/convertComic/wocopy/B"

# 一時ファイルのパス
temp_file="./directories_list.txt"

# ダミーファイルのパス
dummy_file="/Users/Shared/noBackup/dummy/dummy.zip"

# gcpコマンドが利用可能か確認（ない場合はインストールが必要）
if ! command -v gcp &> /dev/null; then
  echo "GNU cp (gcp) is not installed. Please install it first."
  exit 1
fi

# gtouchコマンドが利用可能か確認（ない場合はインストールが必要）
if ! command -v gtouch &> /dev/null; then
  echo "GNU touch (gtouch) is not installed. Please install it first."
  exit 1
fi

# 指定日時以降のディレクトリを一時ファイルに出力
#find "$source_directory" -maxdepth 1 -mindepth 1 -type d -newermt "$specified_date_A" ! -newermt "$specified_date_B"  > "$temp_file"
find "$source_directory" -maxdepth 1 -mindepth 1 -type d -newermt "$specified_date_A"  > "$temp_file"

# ディレクトリに対して拡張子が"wo"のファイルをコピーし、元のソースのタイムスタンプを維持
while IFS= read -r directory; do
  destination="${destination_directory}/${directory#$source_directory}"
  mkdir -p "$destination"

	# 拡張子が"wo"のファイルをgcpでコピー
  find "$directory" -maxdepth 1 -type f -name "*.wo" -exec \
    gcp --preserve=timestamps {} "$destination" \;

		# *_ownfix.zipのファイルを探し、対応する*.zipファイルもしくは*.rarファイルがあればdummyファイルとしてコピー
	  find "$directory" -maxdepth 1 -type f -name "*_ownfix.zip" -exec \
	    bash -c 'zip_file="${1/_ownfix.zip/.zip}"; rar_file="${1/_ownfix.zip/.rar}"; [ -e "${zip_file}" ] && gcp -v --preserve=timestamps "$2" "$3/$(basename "${zip_file}")"; [ -e "${rar_file}" ] && gcp -v --preserve=timestamps "$2" "$3/$(basename "${rar_file}")"' _ {} "$dummy_file" "$destination" \;


  # ディレクトリに元のソースのタイムスタンプを設定
  gtouch --reference="$directory" "$destination"
done < "$temp_file"

# 一時ファイルを削除
rm -f "$temp_file"

read -p "Hit enter: "
