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
  rm -rf FFmpeg
  git clone https://github.com/FFmpeg/FFmpeg.git --depth 1
  cd FFmpeg
  git fetch origin tag ${FFMPEG_TAG}
  git checkout ${FFMPEG_TAG}
  EXTRA_CONF=""
  if [[ "${BUILD_MODE}" == "gpl" ]];then
    export PKG_CONFIG_PATH=${INSTALL_DIR}/lib/pkgconfig
    EXTRA_CONF="--enable-gpl --enable-libx264 --enable-libx265"
  fi

  ./configure \
  --prefix=${OUTPUT} \
  --arch=x86_64 \
  --target-os=linux \
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
  --enable-nvenc --enable-nvdec \
  --enable-vaapi \
  --enable-hwaccel=h264_vaapi,hevc_vaapi,h264_cuvid,hevc_cuvid \
  --disable-doc \
  --disable-debug \
  --enable-small \
  --enable-stripping \
  --enable-lto \
  --extra-cflags="-O3 -flto -fomit-frame-pointer -ffunction-sections -fdata-sections -fno-asynchronous-unwind-tables" \
  --extra-ldflags="-Wl,-gc-sections -flto -Wl,--strip-all" \
  ${EXTRA_CONF}

  make -j$(nproc)
  make install
}

case "$1" in
  build-dep) build-dep ;;
  compile) compile_ffmpeg ;;
esac
