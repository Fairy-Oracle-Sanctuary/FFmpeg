#!/bin/bash
set -e
FFMPEG_TAG="n7.1"
X264_BRANCH="stable"
X265_VER="3.6"
BASE=$(pwd)
INSTALL_DIR=${BASE}/linux_dep
OUTPUT=${BASE}/output-linux-x64-${BUILD_MODE}

build-dep(){
  rm -rf build_dep && mkdir -p build_dep && cd build_dep
  git clone https://code.videolan.org/videolan/x264.git -b ${X264_BRANCH} --depth 1
  cd x264
  ./configure --prefix=${INSTALL_DIR} --enable-static --disable-cli
  make -j$(nproc) install
  cd ..
  git clone https://bitbucket.org/multicoreware/x265_git.git -b ${X265_VER} --depth 1
  cd x265_git/source
  cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DENABLE_SHARED=OFF -DCMAKE_BUILD_TYPE=Release ..
  make -j$(nproc) install
  cd ${BASE}
}

compile_ffmpeg(){
  rm -rf ffmpeg
  git clone https://github.com/FFmpeg/FFmpeg.git -b ${FFMPEG_TAG} --depth 1
  cd ffmpeg
  EXTRA_CONF=""
  if [[ "${BUILD_MODE}" == "gpl" ]];then
    export PKG_CONFIG_PATH=${INSTALL_DIR}/lib/pkgconfig
    EXTRA_CONF="--enable-gpl --enable-libx264 --enable-libx265"
  fi

  ./configure \
  --prefix=${OUTPUT} \
  --arch=x86_64 \
  --target-os=linux \
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
  --enable-vaapi \
  --enable-hwaccel=h264_vaapi,hevc_vaapi,h264_cuvid,hevc_cuvid \
  --disable-doc \
  --disable-debug \
  --enable-stripping \
  --enable-small \
  --extra-cflags="-Os -ffunction-sections -fdata-sections" \
  --extra-ldflags="-Wl,-gc-sections" \
  ${EXTRA_CONF}

  make -j$(nproc)
  make install
}

case "$1" in
  build-dep) build-dep ;;
  compile) compile_ffmpeg ;;
esac
