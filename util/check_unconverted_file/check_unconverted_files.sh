#!/bin/bash
cd $(dirname $0)

# 指定日時A（例: 2022-01-01 00:00:00）
#specified_date_A="2023-09-15 00:00:00"
specified_date_A="2023-12-19 00:00:00"

# 指定日時B（例: 2022-01-02 00:00:00）
specified_date_B="2025-12-31 00:00:00"

# 特定のディレクトリ(A)のパス
source_directory="/Volumes/comic/JDown"
#source_directory="/Users/Shared/noBackup/convertComic/wocopy/A"

# 一時ファイルのパス
temp_file="./directories_list.txt"


# 指定日時以降のディレクトリを一時ファイルに出力
# gfind "$source_directory" -maxdepth 1 -mindepth 1 -type d -newermt "$specified_date_A" ! -newermt "$specified_date_B" > "$temp_file"
gfind "$source_directory" -maxdepth 1 -mindepth 1 -type d -newermt "$specified_date_A" ! -newermt "$specified_date_B" -printf "%T@ %p\n" | sort -n | cut -d ' ' -f 2-  > "$temp_file"

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
      if [ -e "$dir_path/$ownfix_name" ]; then
        ownfix_file_size_mb=$(echo "scale=2; $(stat -f%z "$dir_path/$ownfix_name") / (1024 * 1024)" | bc)
        file_size_mb=$(echo "scale=2; $(stat -f%z "$file") / (1024 * 1024)" | bc)
        # 条件判定と警告の出力
        ratio=$(echo "scale=2; $ownfix_file_size_mb / $file_size_mb * 100" | bc -l)
        if (( $(echo "$ratio >= 80" | bc -l) )); then
            echo "[$ratio%] $dir_path/$ownfix_name @ ownfix_file_size_mb=$ownfix_file_size_mb が file_size_mb=$file_size_mb の $ratio% です。"
            echo "@@$file"
            tag --add CC_WRONG "$dir_path/$ownfix_name"
            tag --add CC_WRONG "$dir_path"
            /Users/Shared/noBackup/convertComic/convertComics.sh "$file"
        fi
      fi
      if [ ! -e "$dir_path/$ownfix_name" ] && [ ! -e "$dir_path/$wo_name" ]; then
        echo "Matching unconvered file found: $file"
      fi
    done
  ' _ {} \;

done < "$temp_file"

# 一時ファイルを削除
#rm -f "$temp_file"
