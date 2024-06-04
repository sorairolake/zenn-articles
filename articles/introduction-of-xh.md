---
title: "Rust製のHTTPieのxhを使ってみた"
emoji: "🌐"
type: "tech"
topics: ["cli", "http", "rust", "web"]
published: true
---

:::message
この記事は個人ブログで公開している[記事](https://sorairolake.github.io/blog/posts/introduction-of-xh/)を加筆、修正したものです。
:::

Rust製の[HTTPie](https://httpie.io/)のようなHTTPクライアントのxhを使ってみたので紹介します。

https://github.com/ducaale/xh

## xhとは

`xh`はHTTPリクエストを送信するための高速で使いやすいコマンドラインHTTPクライアントです[^1]。
パフォーマンスの向上に重点を置いており、HTTPieの優れた設計を可能な限り再実装しています[^1]。

## インストール

`xh`は以下のような方法でインストールすることができます[^2]。

[![Packaging status](https://repology.org/badge/vertical-allrepos/xh.svg?columns=3)](https://repology.org/project/xh/versions)

### ソースコードから

[Cargo](https://doc.rust-lang.org/cargo/index.html)を利用してインストールすることができます。

```sh
cargo install xh
```

### Linux

Alpine Linuxではapkを利用してインストールすることができます。

```sh
apk add xh
```

Arch Linuxでは[pacman](https://archlinux.org/pacman/)を利用してインストールすることができます。

```sh
pacman -S xh
```

DebianやUbuntuではAPTを利用してインストールすることができます。

```sh
apt install xh
```

### FreeBSD

FreeBSDでは[FreshPorts](https://www.freshports.org/)からインストールすることができます。

```sh
pkg install xh
```

### macOS

macOSでは[Homebrew](https://brew.sh/)を利用してインストールすることができます。

```sh
brew install xh
```

### Windows

Windowsでは[WinGet](https://learn.microsoft.com/ja-jp/windows/package-manager/)を利用してインストールすることができます。

```sh
winget add ducaale.xh
```

### その他

インストールスクリプトが提供されているので、これを利用してインストールすることもできます。

Linux & macOS:

```sh
curl -sfL https://raw.githubusercontent.com/ducaale/xh/master/install.sh | sh
```

Windows:

```sh
iwr -useb https://raw.githubusercontent.com/ducaale/xh/master/install.ps1 | iex
```

また、release pageでLinux、macOS、Windows向けのビルド済みバイナリが配布されているので、これを利用することもできます。

https://github.com/ducaale/xh/releases

## 使い方

`GET`リクエストを送信してみます。

```sh
xh httpbin.org/get
```

結果はHTTPieと同様に色付けされており、JSONがシンタックスハイライトされる点も同様です。

![レスポンスの画像](/images/introduction-of-xh/get.webp)

その他の使い方については下記のドキュメントを参照して下さい。

https://httpie.io/docs/cli/3.2.2

## HTTPieとの比較

`xh`はHTTPieを可能な限り再実装していますが、以下のようなHTTPieにはない特徴が存在したり、逆にxhにはない特徴が存在したりするので、紹介します[^3]。

### 長所

#### Rust製

スクリプト言語であるPythonで実装されているHTTPieとは異なり、`xh`はRustで実装されているので起動速度が向上しています。
また、Rustで実装されているのでシングルバイナリにすることも可能で、インストールや配布を簡単に行うこともできます。

#### HTTP/2をサポート

`xh`はHTTP/2をサポートしています。
HTTPieはこの記事を書いた時点ではHTTP/2をサポートしていません。

https://daniel.haxx.se/docs/curl-vs-httpie.html

https://github.com/httpie/cli/issues/692

```sh
xh -h https://example.com
```

![レスポンスの画像](/images/introduction-of-xh/http2.webp)

#### curlのコマンドへの変換機能

`--curl`オプションを使用することで`xh`のコマンドをそれと等価な`curl`のコマンドに変換することができます。

```sh
xh --curl --ssl tls1.3 https://example.com
```

変換した結果は以下のようになります。

```text
curl --tlsv1.3 --tls-max 1.3 https://example.com/
```

### 短所

`xh`はこの記事を書いた時点ではHTTPieの全ての機能を実装していません。
また、`xh`はプラグインには対応していません。

### その他の違い

#### TLSバックエンド

`xh`はデフォルトのTLSバックエンドとしてrustlsを使用します。
rustlsはTLS 1.2以降のみをサポートしているので、デフォルトでは`xh`でTLS 1.1などの古いプロトコルを使用することはできません。

https://github.com/rustls/rustls

```sh
xh --offline --ssl=tls1.1 :
```

以下のような警告が表示されます。

```text
xh: warning: rustls does not support older TLS versions. native-tls will be enabled. Use --native-tls to silence this warning.
```

TLS 1.1などの古いプロトコルを使用する場合は、コンパイル時に`native-tls`機能を有効にしてビルドした上で、実行時に`--native-tls`オプションを指定することで、OpenSSLなどのシステムのTLSライブラリをTLSバックエンドとして使用することができます。
この場合に使用できるプロトコルは、そのTLSライブラリに依存します。

```sh
xh --offline --ssl=tls1.1 --native-tls :
```

#### 出力

フォーマットされた出力は常にUTF-8です。

## 終わりに

Rust製のHTTPieのようなHTTPクライアントのxhを紹介しました。
起動速度が向上していることや、HTTP/2をサポートしているなどHTTPieにはない長所がかなりあると思いました。
また、古いバージョンのTLSをデフォルトではサポートしていない点も個人的には評価できます。
モダンなプロトコルをサポートした手軽に利用できるHTTPクライアントとして使ってみてはどうでしょうか。

[^1]: <https://github.com/ducaale/xh/tree/v0.21.0?tab=readme-ov-file#xh>

[^2]: <https://github.com/ducaale/xh/tree/v0.21.0?tab=readme-ov-file#installation>

[^3]: <https://github.com/ducaale/xh/tree/v0.21.0?tab=readme-ov-file#how-xh-compares-to-httpie>
