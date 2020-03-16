#!/bin/bash
wget -nc `sed -n '/^http/'p $1 | sed -n '$'p` -O index.m3u8 -q --show-progress
#wget -nc `sed -n '/EXT-X-I-FRAME-STREAM-INF/'p m.m3u8 | sed -n '$'p | sed 's/.*URI="\(.*\)".*/\1/g'` -O keyframes.m3u8 -q --show-progress
wget -nc `sed -n '/EXT-X-SESSION-KEY/'p m.m3u8 | sed 's/.*URI="\(.*\)".*/\1/g'` -O encryption.key -q --show-progress
sed 's/".*"/"encryption.key"/g' index.m3u8 > index-offline.m3u8
WEB=`sed -n '/^http/'p m.m3u8 | sed -n '$'p | sed 's/ism.*/ism\//g'`
sed -n '/ts$/p' index.m3u8 | awk -v c="$WEB" '{print c$0}' > download.txt
#wget -nc -i download.txt -q --show-progress && \
aria2c -c -j 3 -i download.txt && \
ffmpeg -allowed_extensions ALL -i index-offline.m3u8 -c copy m.mp4 && \
rm index.m3u8 index-offline.m3u8 encryption.key download.txt
