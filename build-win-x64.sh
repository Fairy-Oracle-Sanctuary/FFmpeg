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
  CROSS=${CROSS_PREFIX} ./configure --prefix=${INSTALL_DIR} --target=x86_64-win64-gcc --enable-static --disable-shared --disable-examples --disable-tools --disable-unit-tests --disable-docs --disable-debug
  make -j$(nproc) install
  cd ..

  git clone https://code.videolan.org/videolan/x264.git --depth 1
  cd x264
  ./configure --prefix=${INSTALL_DIR} --enable-static --disable-cli --cross-prefix=${CROSS_PREFIX} --host=x86_64-w64-mingw32
  make -j$(nproc) install
  cd ..

  git clone https://bitbucket.org/multicoreware/x265_git.git
  cd x265_git/build/linux
  cat > toolchain-x86_64-w64-mingw32.cmake <<'TCM'
set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(CMAKE_C_COMPILER x86_64-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER x86_64-w64-mingw32-g++)
set(CMAKE_RC_COMPILER x86_64-w64-mingw32-windres)
set(CMAKE_FIND_ROOT_PATH /usr/x86_64-w64-mingw32)
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
TCM
  cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} -DENABLE_SHARED=OFF -DENABLE_CLI=OFF -DCMAKE_TOOLCHAIN_FILE=toolchain-x86_64-w64-mingw32.cmake ../../source
  make -j$(nproc) install
  mkdir -p ${INSTALL_DIR}/lib/pkgconfig
  cat > ${INSTALL_DIR}/lib/pkgconfig/x265.pc <<EOF
prefix=${INSTALL_DIR}
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: x265
Description: H.265/HEVC encoder library
Version: 4.1
Libs: -L\${libdir} -lx265 -lstdc++
Libs.private: -lstdc++
Cflags: -I\${includedir}
EOF
  cd ../../..

  git clone https://github.com/mstorsjo/fdk-aac.git --depth 1
  cd fdk-aac
  autoreconf -fiv
  ./configure --prefix=${INSTALL_DIR} --host=x86_64-w64-mingw32 --enable-static --disable-shared
  make -j$(nproc) install
  cd ..

  git clone https://gitlab.xiph.org/xiph/opus.git --depth 1
  cd opus
  ./autogen.sh
  ./configure --prefix=${INSTALL_DIR} --host=x86_64-w64-mingw32 --enable-static --disable-shared --disable-extra-programs --disable-doc
  make -j$(nproc) install
  mkdir -p ${INSTALL_DIR}/lib/pkgconfig
  cat > ${INSTALL_DIR}/lib/pkgconfig/opus.pc <<EOF
prefix=${INSTALL_DIR}
exec_prefix=\${prefix}
libdir=\${prefix}/lib
includedir=\${prefix}/include

Name: Opus
Description: Opus audio codec library
Version: 1.5.2
Libs: -L\${libdir} -lopus
Cflags: -I\${includedir} -I\${includedir}/opus
EOF
  cd ..

  git clone https://github.com/rbrito/lame.git --depth 1
  cd lame
  ./configure --prefix=${INSTALL_DIR} --host=x86_64-w64-mingw32 --enable-static --disable-shared --disable-frontend
  make -j$(nproc) install
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
  export PKG_CONFIG_LIBDIR=${INSTALL_DIR}/lib/pkgconfig

  ./configure \
  --prefix=${OUTPUT} \
  --extra-cflags="-I${INSTALL_DIR}/include" \
  --extra-ldflags="-L${INSTALL_DIR}/lib" \
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
  --enable-encoder=h264_nvenc,hevc_nvenc,libx264,libx265,libvpx_vp9,libmp3lame,libopus,libfdk_aac,mpeg4,mpeg2video,flv,h263,h263p,mjpeg,ffv1,png,bmp,aac,ac3,eac3,flac,opus,pcm_s16le,mp2,vorbis,wavpack,ass,ssa,subrip,srt,webvtt \
  --enable-decoder=h264,hevc,mpeg4,mpeg2video,mpegvideo,vp9,vp8,av1,flv,h263,mjpeg,png,bmp,h264_cuvid,hevc_cuvid,aac,ac3,eac3,mp3,flac,libopus,opus,vorbis,pcm_s16le,mp2,wavpack,ass,ssa,subrip,srt,webvtt \
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
