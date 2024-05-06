---
title: "GoでBLAKE3のmd5sumみたいなものを作った"
emoji: "🐭"
type: "tech"
topics: ["cli", "go"]
published: true
published_at: 2024-05-07 08:00
---

[Go](https://go.dev/)で[BLAKE3](https://github.com/BLAKE3-team/BLAKE3)向けのMD5の`md5sum`やSHA-256の`sha256sum`に相当するコマンドの[`gb3sum`](https://pkg.go.dev/github.com/sorairolake/gb3sum)を作りました。

https://github.com/sorairolake/gb3sum

この記事では`gb3sum`のインストールや使い方、同じような目的のコマンドとの違いについて紹介します。

## インストール

[Homebrew](https://brew.sh/)を使っている場合は`brew install`でインストールできます。

```sh
brew install sorairolake/tap/gb3sum
```

また、`gb3sum`はGoで書かれているので`go install`でインストールすることもできます。

```sh
go install github.com/sorairolake/gb3sum@latest
```

## 使い方

### 基本的な使い方

coreutilsの[cksumの共通オプション](https://www.gnu.org/software/coreutils/manual/html_node/cksum-common-options.html)となるべく互換性があるようにしているので、基本的にはLinuxやFreeBSDの`md5sum`や`sha256sum`などの代替品として利用できます。

チェックサムを計算するときはファイル名を指定して実行するだけです。

```sh
echo "Hello, world!" > foo.txt
gb3sum foo.txt | tee b3sums.txt
```

出力:

```text
94f1675bac4f8bc3c593c63dbf5fe78a0bfda01082af85d5b41a65096db56bff  foo.txt
```

チェックサムの検証は`-c`オプションと所定の形式のチェックサムが書かれたファイルを指定します。

```sh
gb3sum -c b3sums.txt
```

出力:

```text
foo.txt: OK
```

## 比較

### coreutils

`gb3sum`はcoreutilsのcksumの共通オプションとなるべく互換性があるようにはしていますが、いくつか欠けているオプションや独自のオプションがあります。

- ファイルをバイナリモードで読み込むオプション（`-b`）とテキストモードで読み込むオプション（`-t`）はありません。`gb3sum`は常にファイルをバイナリファイルとして扱います。
- 出力行の区切りとしてNULを使用するオプション（`-z`）はありません。`gb3sum`では区切りには常に改行文字を使います。
- BLAKE3は任意の長さのハッシュ値を出力できるのでバイト単位でそれを指定するオプション（`-l`）があります。デフォルトでは32バイト（256ビット）のハッシュ値を出力します。

### b3sum

BLAKE3のリファレンス実装は[`b3sum`](https://crates.io/crates/b3sum)というコマンドを提供しています。
BLAKE3は通常のハッシュ以外にもメッセージ認証符号（MAC）や鍵導出関数（KDF）としても使えるので、`b3sum`は通常のハッシュに加えてそれらも計算できますが、`gb3sum`は通常のハッシュだけに対応しています。
現時点で`gb3sum`だけが対応している機能としては、BSD形式のチェックサムの出力（`--tag`）や、`--ignore-missing`や`--status`などのオプションが実装済みであることがあります。
目的が同様なオプションは同じ名前になっているので、単純にチェックサムの計算と検証をするだけなら互換品として利用できると思います。

## 終わりに

`gb3sum`を紹介しました。
機能的には`b3sum`のGo実装というよりはcoreutilsの[`b2sum`](https://www.gnu.org/software/coreutils/b2sum)に近いものになっていると思います。
BSD形式のチェックサムを出力したい場合やチェックサムを検証するときに`--ignore-missing`などのオプションを使いたい場合に`gb3sum`を使っていただけると幸いです。
