---
title: "コマンドラインでの画像の可逆圧縮方法まとめ"
emoji: "🖼️"
type: "tech"
topics: ["cli", "image"]
published: true
---

コマンドラインで画像を可逆圧縮する方法について備忘録としてまとめておきます。
非可逆圧縮と可逆圧縮の両方に対応している画像ファイルフォーマットが対象です。

## リファレンス実装など

### AVIF

AVIFに可逆圧縮するにはlibavifの`avifenc`が利用できます。

https://github.com/AOMediaCodec/libavif

圧縮時に`-l`（長いオプション: `--lossless`）を指定すると可逆圧縮になります。

```sh
avifenc -l input.png output.avif
```

### HEIC

HEIC（HEIF）に可逆圧縮するにはlibheifの`heif-enc`が利用できます。

https://github.com/strukturag/libheif

圧縮時に`-L`（長いオプション: `--lossless`）と`-p chroma=444`と`--matrix_coefficients=0`を指定すると可逆圧縮になります。

```sh
heif-enc -L -p chroma=444 --matrix_coefficients=0 input.png
```

### JPEG 2000

JPEG 2000に可逆圧縮するにはOpenJPEGの`opj_compress`が利用できます。

https://github.com/uclouvain/openjpeg

デフォルトで可逆圧縮なので追加のオプションは不要です。

```sh
opj_compress -i input.png -o output.jp2
```

### JPEG XL

JPEG XLに可逆圧縮するにはlibjxlの`cjxl`が利用できます。

https://github.com/libjxl/libjxl

圧縮時に`-q 100`（長いオプション: `--quality=100`）を指定すると可逆圧縮になります。

```sh
cjxl -q 100 input.png output.jxl
```

入力がJPEGかGIFの場合はデフォルトで可逆圧縮なのでこのオプションは不要です。

```sh
# JPEG
cjxl input.jpg output.jxl

# GIF
cjxl input.gif output.jxl
```

### WebP

WebPに可逆圧縮するにはlibwebpの`cwebp`が利用できます。

https://chromium.googlesource.com/webm/libwebp/

圧縮時に`-lossless`を指定すると可逆圧縮になります。

```sh
cwebp -lossless input.png -o output.webp
```

## ImageMagick

ImageMagickでは`magick`（古いバージョンでは`convert`）が利用できます。

https://imagemagick.org/

基本的に`-quality 100`を指定すると可逆圧縮になります。
画像ファイルフォーマットによっては他の値を指定したり、このオプションを指定しない場合でも可逆圧縮にできそうです。

```sh
magick -quality 100 input.png output.jxl
```

https://github.com/ImageMagick/ImageMagick/blob/676ba55c79d0128e33570c7cad0a5060d52c7344/coders/jxl.c#L1028-L1032

https://github.com/ImageMagick/ImageMagick/blob/676ba55c79d0128e33570c7cad0a5060d52c7344/coders/webp.c#L1158-L1159

実装上はAVIFとHEICも同じ方法で可逆圧縮できそうですが、実装ミスなのか可逆圧縮できませんでした。

https://github.com/ImageMagick/ImageMagick/blob/676ba55c79d0128e33570c7cad0a5060d52c7344/coders/heic.c#L1258-L1259

https://github.com/ImageMagick/ImageMagick/blob/676ba55c79d0128e33570c7cad0a5060d52c7344/coders/heic.c#L1280

https://github.com/ImageMagick/ImageMagick/blob/676ba55c79d0128e33570c7cad0a5060d52c7344/coders/heic.c#L1334-L1335

## 参考文献

- [Image Formats](https://imagemagick.org/script/formats.php) - ImageMagick
- [JP2 Encoding Options](https://imagemagick.org/script/jp2.php) - ImageMagick
- [WebP Encoding Options](https://imagemagick.org/script/webp.php) - ImageMagick
