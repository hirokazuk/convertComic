#!/bin/bash
cd $(dirname $0)

# 指定日時A（例: 2022-01-01 00:00:00）
specified_date_A="2023-09-15 00:00:00"

# 指定日時B（例: 2022-01-02 00:00:00）
specified_date_B="2024-01-20 00:00:00"

# 特定のディレクトリ(A)のパス
source_directory="/Volumes/comic/JDown"
#source_directory="/Users/Shared/noBackup/convertComic/wocopy/A"

# 一時ファイルのパス
temp_file="./directories_list.txt"


# 指定日時以降のディレクトリを一時ファイルに出力
gfind "$source_directory" -maxdepth 1 -mindepth 1 -type d -newermt "$specified_date_A" ! -newermt "$specified_date_B" > "$temp_file"

# 条件に合致するファイルを抽出
while IFS= read -r directory; do
  #echo directory:"$directory"
  # ディレクトリ内の条件に合致するファイルを探し、条件に合致する場合に処理を行う
  gfind "$directory" -maxdepth 1 -type f ! -name "*_ownfix.zip" -size +40M -exec bash -c '
    for file do
      dir_path=$(dirname "$file")
      base_name=$(basename "$file")
      #ownfix_name="${base_name/.*}_ownfix.zip"
      ownfix_name="$(basename "$file" | sed '\''s/\(.*\)\..*/\1/'\'')_ownfix.zip"
      wo_name="${base_name}.wo"
      if [ ! -e "$dir_path/$ownfix_name" ] && [ ! -e "$dir_path/$wo_name" ]; then
        echo "Matching file found: $file"
        # ここに適切な処理を追加
        # 例えば、ファイルを別のディレクトリにコピーする場合:
        # cp -v "$file" "/path/to/output/"
      fi
    done
  ' _ {} \;

done < "$temp_file"

# 一時ファイルを削除
rm -f "$temp_file"
