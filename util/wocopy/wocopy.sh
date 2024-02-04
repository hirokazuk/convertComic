#!/bin/bash
cd $(dirname $0)

# 指定日時（例: 2022-01-01 00:00:00）
specified_date="2024-01-06 00:00:00"

# 特定のディレクトリ(A)のパス
source_directory="/Volumes/comic/JDown"

# 別の指定ディレクトリ(B)のパス
destination_directory="/Volumes/comic/JDown_wo"

# 一時ファイルのパス
temp_file="./directories_list.txt"

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
find "$source_directory" -maxdepth 1 -mindepth 1 -type d -newermt "$specified_date" > "$temp_file"

# ディレクトリに対して拡張子が"wo"のファイルをコピーし、元のソースのタイムスタンプを維持
while IFS= read -r directory; do
  destination="${destination_directory}/${directory#$source_directory/}"
  mkdir -p "$destination"

  # 拡張子が"wo"のファイルをgcpでコピー
  find "$directory" -maxdepth 1 -type f -name "*.wo" -exec \
    gcp --preserve=timestamps {} "$destination" \;

  # ディレクトリに元のソースのタイムスタンプを設定
  gtouch --reference="$directory" "$destination"
done < "$temp_file"

# 一時ファイルを削除
#rm -f "$temp_file"
