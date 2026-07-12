#!/bin/bash
set -e
FFMPEG_TAG="n7.1"
BASE=$(pwd)
INSTALL_DIR=${BASE}/mac_dep
OUTPUT=${BASE}/output-mac-arm64-${BUILD_MODE}

build-dep(){
  rm -rf build_dep && mkdir -p build_dep && cd build_dep
  git clone https://code.videolan.org/videolan/x264.git -b stable --depth 1
  cd x264
  ./configure \
    --prefix=${INSTALL_DIR} \
    --enable-static \
    --disable-cli \
    --enable-pic
  make -j$(sysctl -n hw.ncpu) install
  cd ${BASE}

  # build x265
  rm -rf x265_build
  mkdir x265_build && cd x265_build
  git clone https://bitbucket.org/multicoreware/x265_git.git -b 3.6 --depth 1
  cd x265_git/source
  cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DENABLE_SHARED=OFF -DCMAKE_BUILD_TYPE=Release ..
  make -j$(sysctl -n hw.ncpu) install
  cd ${BASE}
}

compile_ffmpeg(){
  EXTRA=""
  if [[ "${BUILD_MODE}" == "gpl" ]];then
    export PKG_CONFIG_PATH=${INSTALL_DIR}/lib/pkgconfig
    EXTRA="--enable-gpl --enable-libx264 --enable-libx265"
  fi

  rm -rf ffmpeg
  git clone https://github.com/FFmpeg/FFmpeg.git -b ${FFMPEG_TAG} --depth 1
  cd ffmpeg
  ./configure \
  --prefix=${OUTPUT} \
  --arch=arm64 \
  --target-os=darwin \
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
  --enable-videotoolbox \
  --enable-hwaccel=h264_videotoolbox,hevc_videotoolbox \
  --disable-doc \
  --disable-debug \
  --enable-stripping \
  --enable-small \
  --extra-cflags="-Os -ffunction-sections -fdata-sections" \
  --extra-ldflags="-Wl,-gc-sections" \
  ${EXTRA}

  make -j$(sysctl -n hw.ncpu)
  make install
}

case "$1" in
  build-dep) build-dep ;;
  compile) compile_ffmpeg ;;
esac
