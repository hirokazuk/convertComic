#!/bin/bash
cd `dirname $0`

#backup
mv ./ConvertComic.workflow  ./ConvertComicOriginal.workflow

#install
cp -rp ./ConvertComicOriginal.workflow ./ConvertComic.workflow
open ./ConvertComic.workflow

read -p "Hit enter (after installed!!): "

#restore
mv ./ConvertComicOriginal.workflow  ./ConvertComic.workflow
