#!/bin/bash
set -e
FFMPEG_TAG="n7.1"
BASE=$(pwd)
INSTALL_DIR=${BASE}/mac_dep
OUTPUT=${BASE}/output-mac-arm64

build-dep(){
  rm -rf build_dep && mkdir -p build_dep && cd build_dep

  git clone https://chromium.googlesource.com/webm/libvpx.git --depth 1
  cd libvpx
  ./configure --prefix=${INSTALL_DIR} --target=arm64-darwin20-gcc --enable-static --disable-shared --disable-examples --disable-tools --disable-unit-tests --disable-docs --disable-debug
  make -j$(sysctl -n hw.ncpu) install
  cd ..

  git clone https://code.videolan.org/videolan/x264.git --depth 1
  cd x264
  ./configure --prefix=${INSTALL_DIR} --enable-static --disable-cli --host=aarch64-apple-darwin
  make -j$(sysctl -n hw.ncpu) install
  cd ..

  git clone https://bitbucket.org/multicoreware/x265_git.git
  cd x265_git/build/linux
  cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DENABLE_SHARED=OFF -DENABLE_CLI=OFF ../../source
  make -j$(sysctl -n hw.ncpu) install
  cd ../../..

  git clone https://github.com/mstorsjo/fdk-aac.git --depth 1
  cd fdk-aac
  autoreconf -fiv
  ./configure --prefix=${INSTALL_DIR} --enable-static --disable-shared
  make -j$(sysctl -n hw.ncpu) install
  cd ..

  git clone https://gitlab.xiph.org/xiph/opus.git --depth 1
  cd opus
  ./autogen.sh
  ./configure --prefix=${INSTALL_DIR} --enable-static --disable-shared --disable-extra-programs --disable-doc
  make -j$(sysctl -n hw.ncpu) install
  cd ..

  git clone https://github.com/rbrito/lame.git --depth 1
  cd lame
  ./configure --prefix=${INSTALL_DIR} --enable-static --disable-shared --disable-frontend
  make -j$(sysctl -n hw.ncpu) install
  mkdir -p ${INSTALL_DIR}/lib/pkgconfig
  cat > ${INSTALL_DIR}/lib/pkgconfig/libmp3lame.pc <<EOF
prefix=${INSTALL_DIR}
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: libmp3lame
Description: MP3 encoder library
Version: 3.100
Libs: -L\${libdir} -lmp3lame
Cflags: -I\${includedir}
EOF
  cp ${INSTALL_DIR}/lib/pkgconfig/libmp3lame.pc ${INSTALL_DIR}/lib/pkgconfig/lame.pc
  cd ..

  cd ${BASE}
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
  --extra-cflags="-I${INSTALL_DIR}/include" \
  --extra-ldflags="-L${INSTALL_DIR}/lib" \
  --arch=arm64 \
  --target-os=darwin \
  --disable-everything \
  --disable-programs \
  --enable-ffmpeg \
  --disable-avdevice \
  --disable-postproc \
  --disable-network \
  --enable-protocol=file,pipe \
  --enable-muxer=mp4,mov,matroska,webm,flv,avi,mpegts,rawvideo,wav,mp3,ogg,adts,ac3,flac,null \
  --enable-demuxer=mov,matroska,flv,avi,mpegts,mpegvideo,rawvideo,wav,mp3,ogg,aac,ac3,flac,concat,image2 \
  --enable-encoder=h264_videotoolbox,hevc_videotoolbox,libx264,libx265,libvpx_vp9,libmp3lame,libopus,libfdk_aac,mpeg4,mpeg2video,flv,h263,h263p,mjpeg,ffv1,png,bmp,aac,ac3,eac3,flac,opus,pcm_s16le,mp2,vorbis,wavpack,ass,ssa,subrip,srt,webvtt \
  --enable-decoder=h264,hevc,mpeg4,mpeg2video,mpegvideo,vp9,vp8,av1,flv,h263,mjpeg,png,bmp,aac,ac3,eac3,mp3,flac,libopus,opus,vorbis,pcm_s16le,mp2,wavpack,ass,ssa,subrip,srt,webvtt \
  --enable-parser=h264,hevc,mpeg4video,mpegvideo,vp9,vp8,av1,aac,ac3,flac,opus,mpegaudio,vorbis,mjpeg,png \
  --enable-bsf=h264_mp4toannexb,hevc_mp4toannexb,aac_adtstoasc,extract_extradata,null \
  --enable-filter=buffer,buffersink,abuffer,abuffersink,scale,fps,format,null,crop,transpose,vflip,hflip,pad,setpts,setsar,setdar,yadif,aresample,aformat,anull,volume,atempo \
  --enable-gpl \
  --enable-nonfree \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libvpx \
  --enable-libmp3lame \
  --enable-libopus \
  --enable-libfdk-aac \
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
