#!/bin/bash
set -e
FFMPEG_TAG="n7.1"
CROSS_PREFIX="x86_64-w64-mingw32-"
CC=${CROSS_PREFIX}gcc
BASE=$(pwd)
INSTALL_DIR=${BASE}/win_dep
OUTPUT=${BASE}/output-win64-gpl

build-dep(){
  mkdir -p build_win && cd build_win
  git clone https://code.videolan.org/videolan/x264.git --depth 1
  cd x264
  ./configure --prefix=${INSTALL_DIR} --enable-static --disable-cli --cross-prefix=${CROSS_PREFIX} --host=x86_64-w64-mingw32
  make -j$(nproc) install
  cd ..
  # AMD‑AMF SDK 头文件
  git clone https://github.com/GPUOpen‑Documentation‑Archive/AMF.git --depth 1
  cd ..
  export PKG_CONFIG_PATH=${INSTALL_DIR}/lib/pkgconfig
}

compile_ffmpeg(){
  rm -rf ffmpeg
  git clone https://github.com/FFmpeg/FFmpeg.git -b ${FFMPEG_TAG} --depth 1
  cd ffmpeg
  ./configure \
  --prefix=${OUTPUT} \
  --cross-prefix=${CROSS_PREFIX} \
  --arch=x86_64 \
  --target-os=mingw64 \
  --disable-all \
  --enable-programs=ffmpeg \
  --disable-ffprobe \
  --disable-ffplay \
  --enable-muxer=mp4,mkv \
  --enable-demuxer=mp4,h264,hevc \
  --enable-decoder=h264,hevc,aac,opus \
  --enable-encoder=aac,opus \
  --enable-filter=scale,crop,pad,fade \
  --enable-protocol=file \
  --disable-network \
  --enable-nvenc --enable-nvdec \
  --enable-amf \
  --enable-hwaccel=h264_cuvid,hevc_cuvid \
  --enable-gpl --enable-libx264 \
  --disable-doc \
  --disable-debug \
  --enable-stripping \
  --enable-small \
  --cc=${CC} \
  --extra-cflags="-Os -ffunction-sections -fdata-sections -I${BASE}/build_win/AMF/amf/public/include" \
  --extra-ldflags="-Wl,-gc-sections"

  make -j$(nproc)
  make install
}

build-dep
compile_ffmpeg
