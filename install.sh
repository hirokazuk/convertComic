#!/bin/bash
cd `dirname $0`

#dependency install
if ! command -v magick >/dev/null 2>&1; then
  echo "magick(in imagemagick) コマンドは存在しません。インストールします。"
  brew install imagemagick
fi
if ! command -v unar >/dev/null 2>&1; then
  echo "unar コマンドは存在しません。インストールします。"
  brew install unar
fi
if ! command -v rename >/dev/null 2>&1; then
  echo "rename コマンドは存在しません。インストールします。"
  brew install rename
fi
if ! command -v gfind >/dev/null 2>&1; then
  echo "gfind(in findutils) コマンドは存在しません。インストールします。"
  brew install findutils
fi
if ! command -v pueue >/dev/null 2>&1; then
  echo "pueue コマンドは存在しません。インストールします。"
  brew install pueue
fi
if ! command -v tag >/dev/null 2>&1; then
  echo "tag コマンドは存在しません。インストールします。"
  brew install tag
fi

#backup
mv ./ConvertComic.workflow  ./ConvertComicOriginal.workflow

#install (The original will be removed after installation)
cp -rp ./ConvertComicOriginal.workflow ./ConvertComic.workflow
open ./ConvertComic.workflow

read -p "Hit enter (!after installation!): "

#restore
mv ./ConvertComicOriginal.workflow  ./ConvertComic.workflow
