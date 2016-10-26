#!/bin/bash
# Concatenates N mp4 files with h264 video and aac sound without reencoding.
set -e
OUTPUT="${!#}"
NUM_ARGS=$#
if [[ $NUM_ARGS < 2 ]]; then
  echo Usage: $0 INPUT_MP4_AAC_H264_FILES... OUTPUT 1>&2
  exit 1
fi

FFMPEG_ARG="concat:"
NUMBER=1
TEMPDIR=`mktemp -d`
trap 'rm -rf $TEMPDIR' EXIT
for INPUT in "${@:1:$(($NUM_ARGS-1))}"; do
  TEMP=$TEMPDIR/pipe$NUMBER
  ffmpeg -i "$INPUT" -c copy -bsf:v h264_mp4toannexb -f mpegts -y $TEMP 2>/dev/null &
  if [[ NUMBER = 1 ]]; then
    FFMPEG_ARG="${FFMPEG_ARG}$TEMP"
  else
    FFMPEG_ARG="${FFMPEG_ARG}|$TEMP"
  fi
  NUMBER=$(($NUMBER + 1))
done
ffmpeg -f mpegts -i "$FFMPEG_ARG" -c copy -bsf:a aac_adtstoasc "$OUTPUT"
