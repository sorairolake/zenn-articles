---
title: "Rustで画像ファイルフォーマットのXBMを実装した"
emoji: "🖼️"
type: "tech"
topics: ["image", "rust"]
published: true
---

## はじめに

[Rust](https://www.rust-lang.org/)で画像ファイルフォーマットの[XBM](https://ja.wikipedia.org/wiki/XBM)を実装したので紹介します。

https://github.com/sorairolake/xbm-rs

## XBMとは

XBMは、X Window Systemのカーソルやアイコンで使用される二値画像ファイルフォーマットです。
XBMはプレーンテキストで、以下のようにC言語のソースコードの形式をしています。

```c:image.xbm
#define image_width 8
#define image_height 7
static unsigned char image_bits[] = {
    0x00, 0x1C, 0x24, 0x1C, 0x24, 0x1C, 0x00,
};
```

`#define`で画像の幅や高さを指定し、配列で画像のピクセルを表現します。
ピクセルは0（白）と1（黒）で表され、配列の各値は8ピクセルの情報を持ちます。

XBMには古いX10形式と新しいX11形式の2種類があります。
X10形式はピクセルを16ビット（`short`）単位で格納し、X11形式はピクセルを8ビット（`char`）単位で格納します。

## 実装した理由

私が開発しているQRコードをエンコード・デコードするコマンドで、XBM画像からQRコードをデコードできるようにしたいと思ったので実装しました。

https://github.com/sorairolake/qrtool

## `xbm`クレート

`xbm`クレートは、XBM画像をエンコード・デコードするためのライブラリです。

https://crates.io/crates/xbm

このクレートは[X11形式](https://www.x.org/releases/X11R7.7/doc/libX11/libX11/libX11.html#Manipulating_Bitmaps)だけを実装しており、古いX10形式は実装していません。

以下では、このクレートの特徴について述べます。

### 8の倍数でない幅の画像のサポート

`xbm`クレートは[ImageMagick](https://imagemagick.org/)などと同様に画像の幅が8の倍数でないXBM画像をサポートしています。

```c:width_7.xbm
#define image_width 7
#define image_height 6
static unsigned char image_bits[] = {
    0x00, 0x1C, 0x08, 0x08, 0x1C, 0x00,
};
```

```c:width_14.xbm
#define image_width 14
#define image_height 12
static unsigned char image_bits[] = {
    0x00, 0x00, 0x00, 0x00, 0xF0, 0x03, 0xF0, 0x03, 0xC0, 0x00, 0xC0, 0x00,
    0xC0, 0x00, 0xC0, 0x00, 0xF0, 0x03, 0xF0, 0x03, 0x00, 0x00, 0x00, 0x00,
};
```

なお、ウェブブラウザは過去にXBM画像をサポートしていましたが、画像の幅は8の倍数である必要がありました。

https://developer.mozilla.org/ja/docs/Web/Media/Formats/Image_types#xbm_x_window_system_bitmap_file

### ホットスポットのサポート

`xbm`クレートはXBM画像に任意で設定できるホットスポットをサポートしています。

```c:hotspot.xbm
#define image_width 8
#define image_height 7
#define image_x_hot 4
#define image_y_hot 3
static unsigned char image_bits[] = {
    0x00, 0x1C, 0x24, 0x1C, 0x24, 0x1C, 0x00,
};
```

### `image`クレートのサポート

`xbm`クレートの`Encoder`は[`image`](https://crates.io/crates/image)クレートの`ImageEncoder`トレイトを実装しており、`Decoder`は`ImageDecoder`を実装しています。
これにより`image`クレートの`DynamicImage`と簡単に相互変換することができます。

## 使い方

### エンコード

以下は0（白）と1（黒）のピクセルを表すバイト列をXBM画像にエンコードするコード例です。

```rust
use std::io::Write;

use xbm::Encoder;

// "B" (8x7)
let pixels = b"\x00\x00\x00\x00\x00\x00\x00\x00\
               \x00\x00\x01\x01\x01\x00\x00\x00\
               \x00\x00\x01\x00\x00\x01\x00\x00\
               \x00\x00\x01\x01\x01\x00\x00\x00\
               \x00\x00\x01\x00\x00\x01\x00\x00\
               \x00\x00\x01\x01\x01\x00\x00\x00\
               \x00\x00\x00\x00\x00\x00\x00\x00";

let mut buf = [u8::default(); 132];
let encoder = Encoder::new(buf.as_mut_slice());
encoder.encode(pixels, "image", 8, 7, None, None).unwrap();
assert_eq!(buf, *include_bytes!("../tests/data/basic.xbm"));
```

以下は`image`クレートのサポートを有効にして、PNG画像をXBM画像に変換するコード例です。

```rust
use std::io::Write;

use xbm::Encoder;

let input = image::open("tests/data/qr_code.png").unwrap();

let mut buf = Vec::with_capacity(69454);
let encoder = Encoder::new(buf.by_ref());
input.write_with_encoder(encoder).unwrap();
assert_eq!(buf, include_bytes!("../tests/data/qr_code.xbm"));
```

### デコード

以下はXBM画像を0（白）と1（黒）のピクセルを表すバイト列にデコードするコード例です。

```rust
use std::{fs::File, io::BufReader};

use xbm::Decoder;

// "B" (8x7)
let expected = b"\x00\x00\x00\x00\x00\x00\x00\x00\
                 \x00\x00\x01\x01\x01\x00\x00\x00\
                 \x00\x00\x01\x00\x00\x01\x00\x00\
                 \x00\x00\x01\x01\x01\x00\x00\x00\
                 \x00\x00\x01\x00\x00\x01\x00\x00\
                 \x00\x00\x01\x01\x01\x00\x00\x00\
                 \x00\x00\x00\x00\x00\x00\x00\x00";

let reader = File::open("tests/data/basic.xbm")
    .map(BufReader::new)
    .unwrap();
let decoder = Decoder::new(reader).unwrap();
assert_eq!(decoder.width(), 8);
assert_eq!(decoder.height(), 7);

let mut buf = [u8::default(); 56];
decoder.decode(&mut buf).unwrap();
assert_eq!(buf, *expected);
```

以下は`image`クレートのサポートを有効にして、XBM画像をPNG画像に変換するコード例です。

```rust
use std::{
    fs::File,
    io::{BufReader, Cursor},
};

use xbm::{
    image::{DynamicImage, ImageDecoder, ImageFormat},
    Decoder,
};

let reader = File::open("tests/data/qr_code.xbm")
    .map(BufReader::new)
    .unwrap();
let decoder = Decoder::new(reader).unwrap();
assert_eq!(decoder.dimensions(), (296, 296));
let image = DynamicImage::from_decoder(decoder).unwrap();

let mut writer = Cursor::new(Vec::with_capacity(2091));
image.write_to(&mut writer, ImageFormat::Png).unwrap();

let actual = image::load_from_memory(writer.get_ref()).unwrap();
let expected = image::open("tests/data/qr_code.png").unwrap();
assert_eq!(actual, expected);
```

## 終わりに

`xbm`クレートを紹介しました。
この記事を読んで興味を持った場合には、一度試してもらえると嬉しいです。

詳しい使い方は以下のドキュメントを参照して下さい。

https://docs.rs/xbm
