#!/bin/bash
set -e
FFMPEG_TAG="n7.1"
BASE=$(pwd)
INSTALL_DIR=${BASE}/mac_dep
OUTPUT=${BASE}/output-mac-arm64-${BUILD_MODE}

build-dep(){
  rm -rf build_dep && mkdir -p build_dep && cd build_dep

  if [[ "${BUILD_MODE}" == "gpl" ]]; then
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
    git clone https://bitbucket.org/multicoreware/x265_git.git --depth 1
    cd x265_git
    git fetch origin tag 3.6
    git checkout 3.6
    cd source
    sed -i.bak 's/CMP0025  *OLD)/CMP0025 NEW)/' CMakeLists.txt
    sed -i.bak 's/CMP0054  *OLD)/CMP0054 NEW)/' CMakeLists.txt
    cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_INSTALL_LIBDIR=lib -DENABLE_SHARED=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5 .
    make -j$(sysctl -n hw.ncpu) install
  fi

  cd ${BASE}
}

compile_ffmpeg(){
  export PKG_CONFIG_PATH=${INSTALL_DIR}/lib/pkgconfig
  EXTRA=""
  if [[ "${BUILD_MODE}" == "gpl" ]];then
    EXTRA="--enable-gpl --enable-libx264 --enable-libx265"
  fi

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
  --extra-ldflags="-Wl,-dead_strip -flto" \
  ${EXTRA}

  make -j$(sysctl -n hw.ncpu)
  make install
}

case "$1" in
  build-dep) build-dep ;;
  compile) compile_ffmpeg ;;
esac
