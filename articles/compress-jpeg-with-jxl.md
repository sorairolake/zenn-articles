---
title: "JPEG XLでJPEGを圧縮する"
emoji: "🖼️"
type: "tech"
topics: ["avif", "image", "jpeg", "jxl", "webp"]
published: true
published_at: 2024-03-11 09:30
---

[JPEG XL](https://jpeg.org/jpegxl/)は[JPEG](https://jpeg.org/jpeg/)や[PNG](https://ja.wikipedia.org/wiki/Portable_Network_Graphics)などの従来の形式よりも高い圧縮率を実現しており、非可逆圧縮と可逆圧縮、アニメーション、アルファチャンネル、HDR、広色域などのモダンな機能を提供していますが、これらは部分的も含めて[AVIF](https://aomediacodec.github.io/av1-avif/)や[WebP](https://developers.google.com/speed/webp/)でも対応しています。

JPEG XLのこれらの形式にはない特徴として、従来のJPEGを一切の画質の劣化なくファイルサイズを約20%小さくできるというのがあるので、今回はこれを試してみようと思います。

## 可逆的なJPEGトランスコーディング

[ウィキメディア・コモンズのページ](https://commons.wikimedia.org/wiki/File:Shiba_inu_taiki.jpg)にある以下のJPEG画像をJPEG XLに変換してみます。

![赤毛の柴犬](https://upload.wikimedia.org/wikipedia/commons/5/58/Shiba_inu_taiki.jpg)
_赤毛の柴犬（707,853 B）_

```sh
# WebP
cwebp -lossless Shiba_inu_taiki.jpg -o Shiba_inu_taiki.webp

# AVIF
avifenc -l Shiba_inu_taiki.jpg Shiba_inu_taiki.avif

# JPEG XL
cjxl Shiba_inu_taiki.jpg Shiba_inu_taiki.jxl
```

| コマンド      | バージョン |
| ------------- | ---------- |
| `cwebp`       | 1.3.2      |
| `avifenc`[^1] | 1.0.4      |
| `cjxl`        | 0.10.1     |

### 結果

| 形式    | ファイルサイズ（B） |
| ------- | ------------------- |
| JPEG    | 707,853             |
| WebP    | 2,425,950           |
| AVIF    | 4,750,246           |
| JPEG XL | 576,128             |

![圧縮比の比較](/images/compress-jpeg-with-jxl/comparison-of-compression-results.webp)

WebPとAVIFに可逆圧縮したときはファイルサイズが大きくなり、JPEG XLだけが小さくなるという結果になりました。
また、実際に約20%ファイルサイズが小さくなりました。

## 復元

圧縮した画像からはビット単位で完全に同一のJPEG画像に復元できます。

```sh
# 復元
djxl Shiba_inu_taiki.jxl reconstructed.jpg

# ビット単位で比較
cmp Shiba_inu_taiki.jpg reconstructed.jpg
```

JPEG XLにはExifなどのメタデータを保存できるので、圧縮の際にこれを含めている場合にはこれを含めて完全に復元されます。

```sh
identify -verbose reconstructed.jpg
```

## 終わりに

現状では対応しているのがSafariだけとウェブブラウザの対応はあまり進んでいません。

https://caniuse.com/jpegxl

しかし、対応しているグラフィックソフトウェアは増えてきているので[^2]、ブラウザ以外の環境では積極的に利用できそうです。
また、復元は低コストで行えるので現状でもJPEG画像のサーバー内部での保存形式として良さそうです。

## 参考文献

- [Transitioning JPEG-Based to JPEG XL-Based Images for Web Platforms](https://cloudinary.com/blog/legacy_and_transition_creating_a_new_universal_image_codec) - Cloudinary Blog

[^1]: libaomはバージョン3.8.1を使用。

[^2]: <https://github.com/libjxl/libjxl/blob/v0.10.2/doc/software_support.md>
