#!/bin/bash
set -e
FFMPEG_TAG="n7.1"
BASE=$(pwd)
INSTALL_DIR=${BASE}/mac_dep
OUTPUT=${BASE}/output-mac-arm64

build-dep(){
  :
}

compile_ffmpeg(){
  export PKG_CONFIG_PATH=${INSTALL_DIR}/lib/pkgconfig

  rm -rf FFmpeg
  git clone https://github.com/FFmpeg/FFmpeg.git --depth 1
  cd FFmpeg
  git fetch origin tag ${FFMPEG_TAG}
  git checkout ${FFMPEG_TAG}
  ./configure \
  --prefix=${OUTPUT} \
  --arch=arm64 \
  --target-os=darwin \
  --disable-everything \
  --disable-programs \
  --enable-ffmpeg \
  --enable-encoders \
  --enable-decoders \
  --enable-muxers \
  --enable-demuxers \
  --enable-parsers \
  --enable-bsfs \
  --enable-filters \
  --enable-protocols \
  --disable-avdevice \
  --disable-postproc \
  --disable-network \
  --enable-videotoolbox \
  --enable-hwaccel=h264_videotoolbox,hevc_videotoolbox \
  --disable-doc \
  --disable-debug \
  --enable-small \
  --enable-stripping \
  --enable-lto \
  --extra-cflags="-O3 -flto -fomit-frame-pointer -ffunction-sections -fdata-sections" \
  --extra-ldflags="-Wl,-dead_strip -flto"

  make -j$(sysctl -n hw.ncpu)
  make install
}

case "$1" in
  build-dep) build-dep ;;
  compile) compile_ffmpeg ;;
esac
