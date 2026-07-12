#!/bin/bash
set -e
FFMPEG_TAG="n7.1"
CROSS_PREFIX="x86_64-w64-mingw32-"
CC=${CROSS_PREFIX}gcc
BASE=$(pwd)
INSTALL_DIR=${BASE}/win_dep
OUTPUT=${BASE}/output-win64

build-dep(){
  mkdir -p build_win && cd build_win

  git clone https://github.com/FFmpeg/nv-codec-headers.git --depth 1
  cd nv-codec-headers
  make PREFIX=${INSTALL_DIR} install
  cd ..

  git clone https://chromium.googlesource.com/webm/libvpx.git --depth 1
  cd libvpx
  ./configure --prefix=${INSTALL_DIR} --enable-static --disable-shared --disable-examples --disable-tools --disable-unit-tests --target=x86_64-win64-gcc --cross-prefix=${CROSS_PREFIX}
  make -j$(nproc) install
  cd ..

  cd ..
  export PKG_CONFIG_PATH=${INSTALL_DIR}/lib/pkgconfig
}

compile_ffmpeg(){
  rm -rf FFmpeg
  git clone https://github.com/FFmpeg/FFmpeg.git --depth 1
  cd FFmpeg
  git fetch origin tag ${FFMPEG_TAG}
  git checkout ${FFMPEG_TAG}

  export PKG_CONFIG_PATH=${INSTALL_DIR}/lib/pkgconfig

  ./configure \
  --prefix=${OUTPUT} \
  --cross-prefix=${CROSS_PREFIX} \
  --arch=x86_64 \
  --target-os=mingw64 \
  --disable-everything \
  --disable-programs \
  --enable-ffmpeg \
  --disable-avdevice \
  --disable-postproc \
  --disable-network \
  --enable-protocol=file,pipe \
  --enable-muxer=mp4,mov,matroska,webm,flv,avi,mpegts,rawvideo,wav,mp3,ogg,adts,ac3,flac,null \
  --enable-demuxer=mov,matroska,flv,avi,mpegts,mpegvideo,rawvideo,wav,mp3,ogg,aac,ac3,flac,concat,image2 \
  --enable-encoder=h264_nvenc,hevc_nvenc,libvpx_vp9,mpeg4,mpeg2video,flv,h263,h263p,mjpeg,ffv1,png,bmp,aac,ac3,eac3,flac,opus,pcm_s16le,mp2,vorbis,wavpack,ass,ssa,subrip,srt,webvtt \
  --enable-decoder=h264,hevc,mpeg4,mpeg2video,mpegvideo,vp9,vp8,av1,flv,h263,mjpeg,png,bmp,h264_cuvid,hevc_cuvid,aac,ac3,eac3,mp3,flac,opus,vorbis,pcm_s16le,mp2,wavpack,ass,ssa,subrip,srt,webvtt \
  --enable-parser=h264,hevc,mpeg4video,mpegvideo,vp9,vp8,av1,aac,ac3,flac,opus,mpegaudio,vorbis,mjpeg,png \
  --enable-bsf=h264_mp4toannexb,hevc_mp4toannexb,aac_adtstoasc,extract_extradata,null \
  --enable-filter=buffer,buffersink,abuffer,abuffersink,scale,fps,format,null,crop,transpose,vflip,hflip,pad,setpts,setsar,setdar,yadif,aresample,aformat,anull,volume,atempo \
  --enable-libvpx \
  --enable-nvenc --enable-nvdec \
  --enable-hwaccel=h264_cuvid,hevc_cuvid \
  --disable-doc \
  --disable-debug \
  --enable-small \
  --enable-stripping \
  --enable-lto \
  --cc=${CC} \
  --extra-cflags="-O3 -flto -fomit-frame-pointer -ffunction-sections -fdata-sections -fno-asynchronous-unwind-tables" \
  --extra-ldflags="-Wl,-gc-sections -flto -Wl,--strip-all"

  make -j$(nproc)
  make install
}

case "$1" in
  build-dep) build-dep ;;
  compile) compile_ffmpeg ;;
esac
