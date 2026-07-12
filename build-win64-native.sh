#!/bin/bash
set -e
FFMPEG_TAG="n7.1"
BASE=$(pwd)
INSTALL_DIR=${BASE}/win_dep
OUTPUT=${BASE}/output-win64-${BUILD_MODE}

build-dep(){
  mkdir -p build_win && cd build_win
  if [[ "${BUILD_MODE}" == "gpl" ]]; then
    git clone https://code.videolan.org/videolan/x264.git --depth 1
    cd x264
    ./configure --prefix=${INSTALL_DIR} --enable-static --disable-cli
    make -j$(nproc) install
    cd ..
  fi
  git clone https://github.com/GPUOpen-LibrariesAndSDKs/AMF.git --depth 1
  cd ..
  export PKG_CONFIG_PATH=${INSTALL_DIR}/lib/pkgconfig
}

compile_ffmpeg(){
  rm -rf ffmpeg
  git clone https://github.com/FFmpeg/FFmpeg.git -b ${FFMPEG_TAG} --depth 1
  cd ffmpeg

  EXTRA_CONF=""
  if [[ "${BUILD_MODE}" == "gpl" ]]; then
    export PKG_CONFIG_PATH=${INSTALL_DIR}/lib/pkgconfig
    EXTRA_CONF="--enable-gpl --enable-libx264"
  fi

  ./configure \
  --prefix=${OUTPUT} \
  --arch=x86_64 \
  --target-os=mingw64 \
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
  --enable-amf \
  --enable-hwaccel=h264_cuvid,hevc_cuvid \
  --disable-doc \
  --disable-debug \
  --enable-small \
  --enable-stripping \
  --enable-lto \
  --extra-cflags="-O3 -flto -fomit-frame-pointer -ffunction-sections -fdata-sections -fno-asynchronous-unwind-tables -I${BASE}/build_win/AMF/amf/public/include" \
  --extra-ldflags="-Wl,-gc-sections -flto -Wl,--strip-all" \
  ${EXTRA_CONF}

  make -j$(nproc)
  make install
}

case "$1" in
  build-dep) build-dep ;;
  compile) compile_ffmpeg ;;
esac
