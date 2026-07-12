# FFmpeg 精简版构建说明

基于 FFmpeg n7.1，三平台交叉编译，仅保留常用的音视频编解码器和容器格式，去除了网络、设备采集、后处理等不常用模块，体积约 **2-5 MB**（全量版约 40-55 MB）。

## 支持的平台

| 平台 | 脚本 | 目标 |
|---|---|---|
| Windows x64 | `build-win-x64.sh` | x86_64-w64-mingw32 交叉编译 |
| Linux x64 | `build-linux-x64.sh` | 原生编译 |
| macOS ARM64 | `build-mac-arm.sh` | Apple Silicon 原生编译 |

## 构建方法

```bash
# 1. 编译依赖库（nv-codec-headers / libvpx）
./build-win-x64.sh build-dep

# 2. 编译 FFmpeg
./build-win-x64.sh compile
```

## 已禁用的模块

- **avdevice** — 设备采集（摄像头、麦克风）
- **postproc** — 后处理
- **network** — 网络协议（http/https/rtmp/tcp/udp 等）
- **ffplay** — 播放器
- **ffprobe** — 分析工具
- **doc** — 文档生成
- **debug** — 调试符号

## 支持的协议

| 协议 | 说明 |
|---|---|
| `file` | 本地文件读写 |
| `pipe` | 管道流 |

## 支持的容器格式

### Muxer（封装）

| 格式 | 说明 |
|---|---|
| `mp4` | MP4 容器 |
| `mov` | QuickTime MOV |
| `matroska` | MKV/WebM 容器 |
| `webm` | WebM 容器 |
| `flv` | Flash Video |
| `avi` | AVI |
| `mpegts` | MPEG-TS 传输流 |
| `rawvideo` | 裸视频流 |
| `wav` | WAV 音频 |
| `mp3` | MP3 |
| `ogg` | OGG |
| `adts` | ADTS（AAC 裸流） |
| `ac3` | AC-3 裸流 |
| `flac` | FLAC 裸流 |
| `null` | 丢弃输出 |

### Demuxer（解封装）

| 格式 | 说明 |
|---|---|
| `mov` | MP4/MOV/M4A |
| `matroska` | MKV/WebM |
| `flv` | Flash Video |
| `avi` | AVI |
| `mpegts` | MPEG-TS |
| `mpegvideo` | MPEG 裸流 |
| `rawvideo` | 裸视频流 |
| `wav` | WAV |
| `mp3` | MP3 |
| `ogg` | OGG |
| `aac` | AAC 裸流 |
| `ac3` | AC-3 裸流 |
| `flac` | FLAC 裸流 |
| `concat` | 拼接协议 |
| `image2` | 图像序列 |

## 支持的编码器

### 视频编码器

| 编码器 | 类型 | 平台 | 说明 |
|---|---|---|---|
| `h264_nvenc` | 硬件 | Win/Linux | NVIDIA NVENC H.264 编码 |
| `hevc_nvenc` | 硬件 | Win/Linux | NVIDIA NVENC HEVC 编码 |
| `h264_vaapi` | 硬件 | Linux | VAAPI H.264 编码 |
| `hevc_vaapi` | 硬件 | Linux | VAAPI HEVC 编码 |
| `h264_videotoolbox` | 硬件 | macOS | VideoToolbox H.264 编码 |
| `hevc_videotoolbox` | 硬件 | macOS | VideoToolbox HEVC 编码 |
| `libvpx_vp9` | 软件 | 全平台 | VP9 编码（依赖 libvpx） |
| `mpeg4` | 软件 | 全平台 | MPEG-4 Part 2 |
| `mpeg2video` | 软件 | 全平台 | MPEG-2 Video |
| `flv` | 软件 | 全平台 | FLV/Sorenson H.263 |
| `h263` | 软件 | 全平台 | H.263 |
| `h263p` | 软件 | 全平台 | H.263+ |
| `mjpeg` | 软件 | 全平台 | Motion JPEG |
| `ffv1` | 软件 | 全平台 | FFV1 无损编码 |
| `png` | 软件 | 全平台 | PNG 图像 |
| `bmp` | 软件 | 全平台 | BMP 图像 |

### 音频编码器

| 编码器 | 说明 |
|---|---|
| `aac` | AAC LC |
| `ac3` | Dolby Digital (AC-3) |
| `eac3` | Dolby Digital Plus (E-AC-3) |
| `flac` | FLAC 无损 |
| `opus` | Opus |
| `pcm_s16le` | PCM 16-bit Little-Endian |
| `mp2` | MPEG Audio Layer II |
| `vorbis` | Vorbis |
| `wavpack` | WavPack |

### 字幕编码器

| 编码器 | 说明 |
|---|---|
| `ass` | Advanced SubStation Alpha |
| `ssa` | SubStation Alpha |
| `subrip` | SubRip (SRT) |
| `srt` | SubRip |
| `webvtt` | WebVTT |

## 支持的解码器

### 视频解码器

| 解码器 | 类型 | 说明 |
|---|---|---|
| `h264` | 软件 | H.264 / AVC |
| `hevc` | 软件 | HEVC / H.265 |
| `mpeg4` | 软件 | MPEG-4 Part 2 |
| `mpeg2video` | 软件 | MPEG-2 Video |
| `mpegvideo` | 软件 | MPEG-1/2 Video |
| `vp9` | 软件 | VP9 |
| `vp8` | 软件 | VP8 |
| `av1` | 软件 | AV1 |
| `flv` | 软件 | FLV/Sorenson H.263 |
| `h263` | 软件 | H.263 |
| `mjpeg` | 软件 | Motion JPEG |
| `png` | 软件 | PNG |
| `bmp` | 软件 | BMP |
| `h264_cuvid` | 硬件 | NVIDIA CUVID H.264 解码（Win/Linux） |
| `hevc_cuvid` | 硬件 | NVIDIA CUVID HEVC 解码（Win/Linux） |

### 音频解码器

| 解码器 | 说明 |
|---|---|
| `aac` | AAC LC/HE |
| `ac3` | Dolby Digital (AC-3) |
| `eac3` | Dolby Digital Plus (E-AC-3) |
| `mp3` | MP3 |
| `flac` | FLAC 无损 |
| `opus` | Opus |
| `vorbis` | Vorbis |
| `pcm_s16le` | PCM 16-bit Little-Endian |
| `mp2` | MPEG Audio Layer II |
| `wavpack` | WavPack |

### 字幕解码器

| 解码器 | 说明 |
|---|---|
| `ass` | Advanced SubStation Alpha |
| `ssa` | SubStation Alpha |
| `subrip` | SubRip (SRT) |
| `srt` | SubRip |
| `webvtt` | WebVTT |

## 支持的 Parser

| Parser | 说明 |
|---|---|
| `h264` | H.264 / AVC |
| `hevc` | HEVC / H.265 |
| `mpeg4video` | MPEG-4 Video |
| `mpegvideo` | MPEG-1/2 Video |
| `vp9` | VP9 |
| `vp8` | VP8 |
| `av1` | AV1 |
| `aac` | AAC |
| `ac3` | AC-3 |
| `flac` | FLAC |
| `opus` | Opus |
| `mpegaudio` | MP1/MP2/MP3 |
| `vorbis` | Vorbis |
| `mjpeg` | Motion JPEG |
| `png` | PNG |

## 支持的 Bitstream Filter

| BSF | 说明 |
|---|---|
| `h264_mp4toannexb` | H.264 MP4 到 Annex B 转换 |
| `hevc_mp4toannexb` | HEVC MP4 到 Annex B 转换 |
| `aac_adtstoasc` | AAC ADTS 到 ASC 转换 |
| `extract_extradata` | 提取 extradata |
| `null` | 直通 |

## 支持的滤镜

### 视频滤镜

| 滤镜 | 说明 |
|---|---|
| `scale` | 缩放分辨率 |
| `fps` | 帧率转换 |
| `format` | 像素格式转换 |
| `null` | 直通 |
| `crop` | 裁剪 |
| `transpose` | 旋转 90/180/270 度 |
| `vflip` | 垂直翻转 |
| `hflip` | 水平翻转 |
| `pad` | 填充边距 |
| `setpts` | 修改 PTS |
| `setsar` | 设置 SAR |
| `setdar` | 设置 DAR |
| `yadif` | 去隔行 |

### 音频滤镜

| 滤镜 | 说明 |
|---|---|
| `aresample` | 重采样 |
| `aformat` | 格式约束 |
| `anull` | 直通 |
| `volume` | 音量调节 |
| `atempo` | 变速不变调 |

### 内部滤镜

| 滤镜 | 说明 |
|---|---|
| `buffer` / `buffersink` | 视频帧缓冲 |
| `abuffer` / `abuffersink` | 音频帧缓冲 |

## 硬件加速

| 平台 | 加速方式 | 编码 | 解码 |
|---|---|---|---|
| Windows | NVENC / NVDEC (CUVID) | H.264, HEVC | H.264, HEVC |
| Linux | NVENC / NVDEC (CUVID) | H.264, HEVC | H.264, HEVC |
| Linux | VAAPI | H.264, HEVC | - |
| macOS | VideoToolbox | H.264, HEVC | - |

## 外部依赖

| 依赖 | 用途 | 构建步骤 |
|---|---|---|
| [nv-codec-headers](https://github.com/FFmpeg/nv-codec-headers) | NVENC/NVDEC SDK | `build-dep` 自动编译 |
| [libvpx](https://chromium.googlesource.com/webm/libvpx) | VP8/VP9 编解码 | `build-dep` 自动编译 |

## 编译优化

- `-O3` 最高优化等级
- `-flto` 链接时优化
- `-fomit-frame-pointer` 省略帧指针
- `-ffunction-sections -fdata-sections` + `-Wl,-gc-sections` 消除未引用代码
- `-fno-asynchronous-unwind-tables` 省略异常展开表
- `--enable-small` 启用体积优化
- `--enable-stripping` 去除符号表
- `-Wl,--strip-all` 链接时去除全部符号

## 支持的视频格式转换矩阵

### 可解码的输入视频编码

| 输入编码 | 解码器 | 说明 |
|---|---|---|
| H.264 / AVC | `h264` / `h264_cuvid` | 软解 + NVDEC 硬解（Win/Linux） |
| HEVC / H.265 | `hevc` / `hevc_cuvid` | 软解 + NVDEC 硬解（Win/Linux） |
| MPEG-4 Part 2 | `mpeg4` | DivX / XviD 等 |
| MPEG-2 Video | `mpeg2video` / `mpegvideo` | DVD / SVCD |
| VP9 | `vp9` | WebM 视频 |
| VP8 | `vp8` | WebM 视频 |
| AV1 | `av1` | 新一代编码 |
| FLV / Sorenson H.263 | `flv` | Flash Video |
| H.263 | `h263` | 视频会议 |
| Motion JPEG | `mjpeg` | MJPEG |
| PNG | `png` | 图像序列 |
| BMP | `bmp` | 图像序列 |

### 可编码的输出视频编码

| 输出编码 | 编码器 | 平台 | 说明 |
|---|---|---|---|
| H.264 / AVC | `h264_nvenc` | Win/Linux | NVIDIA 硬件编码 |
| H.264 / AVC | `h264_vaapi` | Linux | Intel/AMD VAAPI 硬件编码 |
| H.264 / AVC | `h264_videotoolbox` | macOS | Apple 硬件编码 |
| HEVC / H.265 | `hevc_nvenc` | Win/Linux | NVIDIA 硬件编码 |
| HEVC / H.265 | `hevc_vaapi` | Linux | Intel/AMD VAAPI 硬件编码 |
| HEVC / H.265 | `hevc_videotoolbox` | macOS | Apple 硬件编码 |
| VP9 | `libvpx_vp9` | 全平台 | 软件编码（libvpx） |
| MPEG-4 Part 2 | `mpeg4` | 全平台 | 软件编码 |
| MPEG-2 Video | `mpeg2video` | 全平台 | 软件编码 |
| FLV / Sorenson H.263 | `flv` | 全平台 | 软件编码 |
| H.263 | `h263` / `h263p` | 全平台 | 软件编码 |
| Motion JPEG | `mjpeg` | 全平台 | 软件编码 |
| FFV1 | `ffv1` | 全平台 | 无损编码 |
| PNG | `png` | 全平台 | 图像序列 |
| BMP | `bmp` | 全平台 | 图像序列 |

### 容器转换矩阵

以下容器之间可以互相转换（`-c copy` 纯封装复制或重编码均可）：

| 输入容器 \ 输出容器 | MP4 | MOV | MKV | WebM | FLV | AVI | MPEG-TS | WAV | MP3 | OGG | ADTS | AC3 | FLAC |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **MP4/MOV** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **MKV** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **WebM** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **FLV** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **AVI** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **MPEG-TS** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| **MPEG Video** | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | - | - | - | - | - | - |
| **WAV** | - | - | - | - | - | - | - | ✅ | ✅ | ✅ | - | - | ✅ |
| **MP3** | - | - | - | - | - | - | - | ✅ | ✅ | ✅ | - | - | - |
| **OGG** | - | - | - | - | - | - | - | ✅ | ✅ | ✅ | - | - | ✅ |
| **AAC** | - | - | - | - | - | - | - | - | - | - | ✅ | - | - |
| **AC3** | - | - | - | - | - | - | - | - | - | - | - | ✅ | - |
| **FLAC** | - | - | - | - | - | - | - | ✅ | - | ✅ | - | - | ✅ |

> **注意**：纯音频容器（WAV/MP3/OGG/AAC/AC3/FLAC）只能输出到支持音频流的容器。视频容器之间的转换需要编解码器兼容（见下文）。

### 常见转换场景

| 场景 | 命令 |
|---|---|
| MP4 → MKV（不重编码） | `ffmpeg -i input.mp4 -c copy output.mkv` |
| MKV → MP4（不重编码） | `ffmpeg -i input.mkv -c copy output.mp4` |
| MP4 → WebM（VP9+Opus） | `ffmpeg -i input.mp4 -c:v libvpx-vp9 -crf 32 -b:v 0 -c:a libopus -b:a 96k output.webm` |
| WebM → MP4（H.264+AAC） | `ffmpeg -i input.webm -c:v h264_nvenc -cq 28 -b:v 0 -c:a aac -b:a 96k output.mp4` |
| FLV → MP4 | `ffmpeg -i input.flv -c:v h264_nvenc -c:a aac output.mp4` |
| AVI → MP4 | `ffmpeg -i input.avi -c:v h264_nvenc -c:a aac output.mp4` |
| MPEG-TS → MP4 | `ffmpeg -i input.ts -c:v h264_nvenc -c:a aac output.mp4` |
| MP4 → FLV | `ffmpeg -i input.mp4 -c:v flv -c:a aac output.flv` |
| HEVC → H.264 | `ffmpeg -i input.mp4 -c:v h264_nvenc -c:a aac output.mp4` |
| H.264 → HEVC | `ffmpeg -i input.mp4 -c:v hevc_nvenc -c:a aac output.mp4` |
| VP9 → H.264 | `ffmpeg -i input.webm -c:v h264_nvenc -c:a aac output.mp4` |
| AV1 → HEVC | `ffmpeg -i input.mp4 -c:v hevc_nvenc -c:a aac output.mp4` |
| 任意 → MPEG-2 | `ffmpeg -i input.mp4 -c:v mpeg2video -c:a mp2 output.mpg` |
| 任意 → FFV1 无损 | `ffmpeg -i input.mp4 -c:v ffv1 -c:a flac output.mkv` |
| 视频抽帧为 PNG | `ffmpeg -i input.mp4 -c:v png -f image2 frame_%04d.png` |

### 编解码兼容性说明

纯封装复制（`-c copy`）要求输入流的编码格式在输出容器中也被支持：

| 编码格式 | MP4 | MOV | MKV | WebM | FLV | AVI | MPEG-TS |
|---|---|---|---|---|---|---|---|
| H.264 | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ |
| HEVC | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |
| VP9 | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| VP8 | ❌ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| AV1 | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| MPEG-4 | ✅ | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ |
| MPEG-2 | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ | ✅ |
| FLV/H.263 | ❌ | ❌ | ✅ | ❌ | ✅ | ✅ | ❌ |
| MJPEG | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ | ❌ |
| FFV1 | ❌ | ❌ | ✅ | ❌ | ❌ | ✅ | ❌ |

> ❌ 表示该编码格式不适合放入该容器，需要重编码（不要用 `-c copy`）。

## 常用命令示例

### H.264 NVENC 压缩

```bash
ffmpeg -i input.mp4 -c:v h264_nvenc -preset p6 -cq 28 -b:v 0 -c:a aac -b:a 96k output.mp4
```

### VP9 压缩

```bash
ffmpeg -i input.mp4 -c:v libvpx-vp9 -crf 32 -b:v 0 -row-mt 1 -c:a libopus -b:a 96k output.webm
```

### 纯封装转换（不重编码）

```bash
ffmpeg -i input.mkv -c copy output.mp4
```

### 缩小分辨率

```bash
ffmpeg -i input.mp4 -vf scale=1280:-2 -c:v h264_nvenc -c:a aac output_720p.mp4
```

### 抽取音频

```bash
ffmpeg -i input.mp4 -vn -c:a aac output.aac
```

## 体积对比

| 版本 | 预估大小 |
|---|---|
| 官方全量静态构建 | ~40-55 MB |
| 本精简版 | ~2-5 MB |
