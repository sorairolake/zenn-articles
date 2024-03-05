---
title: "QRコードを読み書きするコマンドを開発している話"
emoji: "🛠️"
type: "tech"
topics: ["cli", "qrコード", "rust"]
published: true
published_at: 2024-03-05 12:30
---

QRコードを読み書きするコマンドの`qrtool`を開発しているので紹介します。

![qrtoolのスクリーンショット](/images/introduction-of-qrtool/screenshot.webp)

## qrtoolとは

qrtoolは[Rust](https://www.rust-lang.org/)で書かれた[QRコード](https://www.qrcode.com/)を読み書きするためのコマンドラインユーティリティです。

https://github.com/sorairolake/qrtool

このプログラムは[`qrencode`](https://fukuchi.org/works/qrencode/)と[`zbarimg`](https://github.com/mchehab/zbar)から着想を得ています。

## インストール方法

[![Packaging status](https://repology.org/badge/vertical-allrepos/qrtool.svg?columns=3)](https://repology.org/project/qrtool/versions)

### ソースコードから

[Cargo](https://doc.rust-lang.org/cargo/index.html)を利用してインストールすることができます。

```sh
cargo install qrtool
```

### ビルド済みバイナリから

[リリースページ](https://github.com/sorairolake/qrtool/releases)でLinux、macOS、Windows向けのビルド済みバイナリを公開しているので、これをインストールすることもできます。

## 使い方

### 基本的な使い方

「QR code」という文字列をQRコードにエンコードするには以下のようにします:

```sh
qrtool encode "QR code" > output.png
```

![出力](/images/introduction-of-qrtool/basic.webp)
_出力される画像_

この画像をデコードするには以下のようにします:

```sh
qrtool decode output.png
```

出力される文字列:

```text
QR code
```

エンコードの際に`-t`オプションを使用すると出力形式を変更できます。
デフォルトは`png`ですが、`svg`か`terminal`（ターミナルにUTF-8文字列として出力）として出力することもできます。

### マイクロQRコードの生成

qrtoolはデフォルトでは通常のQRコード（`normal`）を生成しますが、`--variant`オプションに`micro`を指定することで[マイクロQRコード](https://www.qrcode.com/codes/microqr.html)を生成することができます。

#### 例

```sh
qrtool encode -v 3 --variant micro "QR code" > output.png
```

![出力](/images/introduction-of-qrtool/micro.webp)
_出力される画像_

### 色付きのQRコードを出力する

エンコードの際に`--foreground`オプション（デフォルトは`<named-color>`の`black`）を使うと前景色を変更することができ、`--background`オプション（デフォルトは`<named-color>`の`white`）を使うと背景色を変更することができます。

値には以下のいずれかの[CSS color string](https://www.w3.org/TR/css-color-4/)を取ります:

- [`<named-color>`](https://developer.mozilla.org/ja/docs/Web/CSS/named-color)
- [`<hex-color>`](https://developer.mozilla.org/ja/docs/Web/CSS/hex-color)
- [`hsl()`](https://developer.mozilla.org/ja/docs/Web/CSS/color_value/hsl)
- [`hwb()`](https://developer.mozilla.org/ja/docs/Web/CSS/color_value/hwb)
- [`rgb()`](https://developer.mozilla.org/ja/docs/Web/CSS/color_value/rgb)

#### 例

```sh
qrtool encode --foreground brown --background lightslategray "QR code" > output.png
```

![出力](/images/introduction-of-qrtool/rgb.webp)
_出力される画像_

### デコードできる画像ファイルフォーマット

`qrtool decode`は以下の画像ファイルフォーマットをサポートしています:

- [BMP](https://ja.wikipedia.org/wiki/Windows_bitmap)
- [DDS](https://ja.wikipedia.org/wiki/DirectDraw_Surface)
- [Farbfeld](https://tools.suckless.org/farbfeld/)
- [GIF](https://ja.wikipedia.org/wiki/Graphics_Interchange_Format)
- [Radiance RGBE](https://en.wikipedia.org/wiki/RGBE_image_format)
- [ICO](<https://ja.wikipedia.org/wiki/ICO_(%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%83%95%E3%82%A9%E3%83%BC%E3%83%9E%E3%83%83%E3%83%88)>)
- [JPEG](https://jpeg.org/jpeg/)
- [OpenEXR](https://openexr.com/)
- [PNG](https://ja.wikipedia.org/wiki/Portable_Network_Graphics)
- [PNM](https://netpbm.sourceforge.net/doc/pnm.html)
- [QOI](https://qoiformat.org/)
- [SVG](https://www.w3.org/Graphics/SVG/)
- [TGA](https://ja.wikipedia.org/wiki/TGA)
- [TIFF](https://ja.wikipedia.org/wiki/Tagged_Image_File_Format)
- [WebP](https://developers.google.com/speed/webp/)

これは[`image`](https://crates.io/crates/image)クレートがデコードできる全ての画像ファイルフォーマットと[`resvg`](https://crates.io/crates/resvg)クレートによるものです。
ファイルフォーマットは画像のマジックナンバーから自動的に決定し、それが失敗した場合は拡張子に基づいて決定します。
`-t`オプションを使用するとこれらの動作を無視してファイルフォーマットを指定することができます。

#### 例

![入力](/images/introduction-of-qrtool/basic.webp)
_入力する画像_

```sh
qrtool decode input.webp
# または
qrtool decode -t webp input.webp
```

出力:

```text
QR code
```

### 補完スクリプトの生成

`--generate-completion`オプションを使用することで以下のシェル向けの補完スクリプトを生成できます:

- `bash`
- `elvish`
- `fish`
- `nushell`
- `powershell`
- `zsh`

#### 例

```sh
qrtool --generate-completion bash > qrtool.bash
```

### 他のプログラムとの連携

`qrtool encode`と`qrtool decode`はどちらも標準入力からの読み取りと標準出力への書き込みができるので、他のプログラムと容易に連携することができます。

#### 出力される画像の最適化

`qrtool encode`の出力するPNG画像はアルファチャンネルが不要な場合やモノクロの場合でも32ビットRGBA形式で出力します。
これはそのような場合に24ビットRGB形式などに切り替えるのはプログラムが複雑になりそうですし、対応しても最適化された画像の出力は難しいと思ったからです。
もし、画像のサイズを減らしたい場合にはリダイレクトと画像最適化ツールを利用することで簡単にそれを実現することができます。

PNG画像の最適化をしたい場合は以下のようにします:

```sh
qrtool encode "QR code" | oxipng - > output.png
```

https://github.com/shssoichiro/oxipng

SVG画像の最適化をしたい場合は以下のようにします:

```sh
qrtool encode -t svg "QR code" | svgcleaner -c - > output.svg
```

https://github.com/RazrFalcon/svgcleaner

#### 対応していない画像ファイルフォーマットの読み取りと書き込み

PNGかSVG以外の画像ファイルフォーマットで保存したい場合や、デコードできないファイルフォーマットの画像をデコードしたい場合には、[ImageMagick](https://imagemagick.org/)などのコマンドとリダイレクトを利用します。

標準入力から`Cargo.toml`を読み取ってエンコードした結果を[JPEG XL](https://jpeg.org/jpegxl/)画像として保存する:

```sh
cat Cargo.toml | qrtool encode | magick png:- output.jxl
```

保存した画像をデコードして[`bat`](https://github.com/sharkdp/bat)を使って表示する:

```sh
magick output.jxl png:- | qrtool decode | bat -l toml
```

## 終わりに

より詳しいことについてはホームページで見ることができます。

https://sorairolake.github.io/qrtool/book/index.html
