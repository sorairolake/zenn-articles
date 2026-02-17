---
title: "Rustでzopfliコマンドを作った話"
emoji: "🦀"
type: "tech"
topics: ["cli", "gzip", "rust"]
published: true
---

`zopfli`コマンドの[Rust](https://www.rust-lang.org/)実装の`rzopfli`を開発しました。

https://github.com/sorairolake/rzopfli

## Zopfliとは

ZopfliはGoogleが開発した[DEFLATE](https://datatracker.ietf.org/doc/html/rfc1951)形式、[gzip](https://datatracker.ietf.org/doc/html/rfc1952)形式、[zlib](https://datatracker.ietf.org/doc/html/rfc1950)形式と互換性のある可逆データ圧縮アルゴリズムです。

https://github.com/google/zopfli

Zopfliはデータを圧縮するときにより多くの時間を使うことで他のDEFLATEやzlibの実装よりも高い圧縮率を実現しています。
Zopfliが生成するDEFLATEストリームは他のDEFLATEやzlibの実装が出力するDEFLATEストリームと同じくらいの時間で展開できます。

リファレンス実装にはデータを生のDEFLATEストリーム、gzipファイル、zlibファイルに圧縮する`zopfli`コマンドと、Zopfliを使って[PNG](https://ja.wikipedia.org/wiki/Portable_Network_Graphics)画像を最適化する`zopflipng`コマンドが付属しています。

## 作った理由

1. `zopfli`コマンドの機能が不足しているように感じたから。
2. Rustで何かを作りたかったから。

## インストール方法

### ソースコードから

[Cargo](https://doc.rust-lang.org/cargo/index.html)を利用してインストールすることができます。

```sh
cargo install rzopfli
```

### ビルド済みバイナリから

[リリースページ](https://github.com/sorairolake/rzopfli/releases)でLinux、macOS、Windows向けのビルド済みバイナリを公開しているので、これをインストールすることもできます。

## 使い方

`rzopfli`のコマンドライン構文は[`gzip(1)`](https://manpages.debian.org/bookworm/manpages-ja/gzip.1.ja.html)と[`zstd(1)`](https://manpages.debian.org/bookworm/zstd/zstd.1.en.html)を参考にして、そこに`zopfli`コマンドのいくつかのオプションを追加しています。

```sh
$ rzopfli -h
A lossless data compression tool using Zopfli

Usage: rzopfli [OPTIONS] [FILE]...

Arguments:
  [FILE]...  Files to compress

Options:
  -c, --stdout                       Write to standard output, keep original files
  -f, --force                        Force compression even if the output file already exists
  -k, --keep                         Keep input files
      --rm                           Remove input files after successful compression
  -i, --iteration <TIMES>            Perform compression for the specified number of iterations
                                     [default: 15]
      --format <FORMAT>              Output to the specified format [default: gzip] [possible
                                     values: gzip, zlib, deflate]
      --log-level <LEVEL>            The minimum log level to print [default: INFO] [possible
                                     values: OFF, ERROR, WARN, INFO, DEBUG, TRACE]
      --generate-completion <SHELL>  Generate shell completion [possible values: bash, elvish, fish,
                                     nushell, powershell, zsh]
  -h, --help                         Print help (see more with '--help')
  -V, --version                      Print version
```

デフォルトでは、`zstd`コマンドと同様に入力されたファイルを削除しないようになっています。
`zstd`コマンドと同様に`--rm`オプションを指定することで圧縮が成功した後に入力されたファイルを自動的に削除できます。

### データを圧縮する

何もオプションを指定しないときは引数に指定されたファイルをgzipに圧縮します。

```sh
$ rzopfli foo.txt
12:38:15 [INFO] Saving to: foo.txt.gz
12:38:15 [INFO] Original Size: 1.04 KiB, Compressed: 614 B, Compression: 42.46% Removed
```

`--format`オプションを指定すると出力形式をgzipファイル（デフォルト）、zlibファイル、zlibファイルに変更できます。

```sh
$ rzopfli --format zlib foo.txt
12:41:26 [INFO] Saving to: foo.txt.zlib
12:41:26 [INFO] Original Size: 1.04 KiB, Compressed: 602 B, Compression: 43.58% Removed
```

### 圧縮処理の反復回数を変更する

デフォルトでは、`rzopfli`は`zopfli`コマンドと同様に15回圧縮処理を反復します。
`-i`オプションを指定することで`zopfli`コマンドの`--i`オプションのように圧縮処理の反復回数を変更できます。

```sh
$ rzopfli -i 1000 foo.txt
12:49:37 [INFO] Saving to: foo.txt.gz
12:49:38 [INFO] Original Size: 1.04 KiB, Compressed: 612 B, Compression: 42.64% Removed
```

## 終わりに

`rzopfli`を紹介しました。
この記事を読んで興味を持った場合は、実際に`rzopfli`を試していただけると嬉しいです。
