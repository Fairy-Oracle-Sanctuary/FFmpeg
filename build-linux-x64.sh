#!/bin/bash
set -e
FFMPEG_TAG="n7.1"
BASE=$(pwd)
INSTALL_DIR=${BASE}/linux_dep
OUTPUT=${BASE}/output-linux-x64
JOBS=$(nproc)

build-dep(){
  rm -rf build_dep && mkdir -p build_dep && cd build_dep

  # nv-codec-headers
  git clone https://github.com/FFmpeg/nv-codec-headers.git --depth 1
  cd nv-codec-headers
  make PREFIX=${INSTALL_DIR} install
  cd ..

  # libvpx
  git clone https://chromium.googlesource.com/webm/libvpx --depth 1
  cd libvpx
  ./configure --prefix=${INSTALL_DIR} --disable-examples --disable-unit-tests --disable-docs --enable-vp8 --enable-vp9 --enable-static --disable-shared
  make -j${JOBS} install
  cd ..

  # x264
  git clone https://code.videolan.org/videolan/x264.git -b stable --depth 1
  cd x264
  ./configure --prefix=${INSTALL_DIR} --enable-static --disable-cli --enable-pic
  make -j${JOBS} install
  cd ..

  # x265
  git clone https://bitbucket.org/multicoreware/x265_git.git --depth 1
  cd x265_git
  git fetch origin tag 3.6
  git checkout 3.6
  cd source
  sed -i.bak 's/CMP0025  *OLD)/CMP0025 NEW)/' CMakeLists.txt
  sed -i.bak 's/CMP0054  *OLD)/CMP0054 NEW)/' CMakeLists.txt
  cmake -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DCMAKE_INSTALL_LIBDIR=lib -DENABLE_SHARED=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_POLICY_VERSION_MINIMUM=3.5 .
  make -j${JOBS} install
  mkdir -p ${INSTALL_DIR}/lib/pkgconfig
  cat > ${INSTALL_DIR}/lib/pkgconfig/x265.pc << PCEOF
prefix=${INSTALL_DIR}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include
Name: x265
Description: H.265/HEVC video encoder
Version: 3.6
Libs: -L\${libdir} -lx265 -lstdc++ -lpthread -lm -ldl
Libs.private: -lstdc++ -lpthread -lm -ldl
Cflags: -I\${includedir}
PCEOF
  cd ${BASE}

  # fdk-aac
  rm -rf fdk_build && mkdir fdk_build && cd fdk_build
  git clone https://github.com/mstorsjo/fdk-aac.git --depth 1
  cd fdk-aac
  autoreconf -fiv
  ./configure --prefix=${INSTALL_DIR} --libdir=${INSTALL_DIR}/lib --enable-static --disable-shared
  make -j${JOBS} install
  cd ${BASE}

  # opus
  rm -rf opus_build && mkdir opus_build && cd opus_build
  git clone https://github.com/xiph/opus.git --depth 1
  cd opus
  autoreconf -fiv
  ./configure --prefix=${INSTALL_DIR} --libdir=${INSTALL_DIR}/lib --enable-static --disable-shared
  make -j${JOBS} install
  mkdir -p ${INSTALL_DIR}/lib/pkgconfig
  cat > ${INSTALL_DIR}/lib/pkgconfig/opus.pc << PCEOF
prefix=${INSTALL_DIR}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include
Name: Opus
Description: Opus IETF audio codec
Version: 1.4
Libs: -L\${libdir} -lopus -lm
Cflags: -I\${includedir}
PCEOF
  cd ${BASE}

  # lame
  rm -rf lame_build && mkdir lame_build && cd lame_build
  curl -L -o lame.tar.gz https://sourceforge.net/projects/lame/files/lame/3.100/lame-3.100.tar.gz/download
  tar xzf lame.tar.gz
  cd lame-3.100
  ./configure --prefix=${INSTALL_DIR} --libdir=${INSTALL_DIR}/lib --enable-static --disable-shared
  make -j${JOBS} install
  mkdir -p ${INSTALL_DIR}/lib/pkgconfig
  cat > ${INSTALL_DIR}/lib/pkgconfig/libmp3lame.pc << PCEOF
prefix=${INSTALL_DIR}
exec_prefix=\${prefix}
libdir=\${exec_prefix}/lib
includedir=\${prefix}/include
Name: libmp3lame
Description: MP3 encoding library
Version: 3.100
Libs: -L\${libdir} -lmp3lame -lm
Cflags: -I\${includedir}
PCEOF
  cp ${INSTALL_DIR}/lib/pkgconfig/libmp3lame.pc ${INSTALL_DIR}/lib/pkgconfig/lame.pc
  ls -la ${INSTALL_DIR}/lib/pkgconfig/
  cd ${BASE}
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
  --arch=x86_64 \
  --target-os=linux \
  --disable-everything \
  --disable-programs \
  --enable-ffmpeg \
  --disable-avdevice \
  --disable-postproc \
  --disable-network \
  --disable-doc \
  --disable-debug \
  --enable-small \
  --enable-stripping \
  --enable-lto \
  --enable-gpl \
  --enable-nonfree \
  --extra-cflags="-O3 -flto -fomit-frame-pointer -ffunction-sections -fdata-sections -fno-asynchronous-unwind-tables -I${INSTALL_DIR}/include" \
  --extra-ldflags="-Wl,-gc-sections -flto -Wl,--strip-all -L${INSTALL_DIR}/lib" \
  --enable-libx264 \
  --enable-libx265 \
  --enable-libvpx \
  --enable-libfdk-aac \
  --enable-libmp3lame \
  --enable-libopus \
  --pkg-config-flags="--static" \
  --enable-nvenc \
  --enable-nvdec \
  --enable-vaapi \
  --enable-hwaccel=h264_vaapi,hevc_vaapi,h264_cuvid,hevc_cuvid \
  --enable-encoder=libx264,libx265,libvpx_vp9,mpeg4,mpeg2video,flv,h263,h263p,mjpeg,ffv1,png,bmp \
  --enable-encoder=h264_nvenc,hevc_nvenc,h264_vaapi,hevc_vaapi \
  --enable-encoder=libfdk_aac,libmp3lame,libopus,aac,ac3,eac3,flac,opus,pcm_s16le,mp2,vorbis,wavpack \
  --enable-encoder=ass,ssa,subrip,srt,webvtt \
  --enable-decoder=h264,hevc,mpeg4,mpeg2video,mpegvideo,vp9,vp8,av1,flv,h263,mjpeg,png,bmp \
  --enable-decoder=h264_cuvid,hevc_cuvid \
  --enable-decoder=aac,ac3,eac3,mp3,flac,libopus,opus,vorbis,pcm_s16le,mp2,wavpack \
  --enable-decoder=ass,ssa,subrip,srt,webvtt \
  --enable-muxer=mp4,mov,matroska,webm,flv,avi,mpegts,rawvideo,wav,mp3,ogg,adts,ac3,flac,null \
  --enable-demuxer=mov,matroska,webm,flv,avi,mpegts,mpegvideo,rawvideo,wav,mp3,ogg,aac,ac3,flac,concat,image2 \
  --enable-parser=h264,hevc,mpeg4video,mpegvideo,vp9,vp8,av1,aac,ac3,flac,opus,mpegaudio,vorbis,mjpeg,png \
  --enable-bsf=h264_mp4toannexb,hevc_mp4toannexb,aac_adtstoasc,extract_extradata,null \
  --enable-filter=buffer,buffersink,scale,fps,format,null,crop,transpose,vflip,hflip,pad,setpts,setsar,setdar,yadif \
  --enable-filter=abuffer,abuffersink,aresample,aformat,anull,volume,atempo \
  --enable-protocol=file,pipe

  make -j${JOBS}
  make install
}

case "$1" in
  build-dep) build-dep ;;
  compile) compile_ffmpeg ;;
esac
