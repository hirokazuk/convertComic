#!/bin/bash
cd $(dirname $0)

# 引数で渡されたディレクトリパスを取得
directories=("$@")

# 各ディレクトリに対して処理を行う
for dir in "${directories[@]}"; do
    # ディレクトリが存在するか確認
    if [ -d "$dir" ]; then
        # ディレクトリ内の最新のファイルを取得
        latest_file=$(gfind "$dir" -type f -not -name ".*" -printf "%T@ %p\n" | sort -n | tail -1 | cut -d' ' -f2-)

        # 最新のファイルが存在するか確認
        if [ -n "$latest_file" ]; then
            # ファイルの最新のタイムスタンプを取得
            timestamp=$(date -r "$latest_file" "+%Y%m%d%H%M.%S")

            # ディレクトリのタイムスタンプを設定
            touch -c -t "$timestamp" "$dir"

            echo "ディレクトリ $dir のタイムスタンプを最新のファイルのタイムスタンプ ${timestamp} に設定しました。"
        else
            echo "ディレクトリ $dir 内にファイルが見つかりませんでした。"
        fi
    else
        echo "ディレクトリ $dir が存在しません。"
    fi
done
