---
title: "coreutilsはBLAKE2チェックサムの計算と検証ができる"
emoji: "🐮"
type: "tech"
topics: ["cli"]
published: true
published_at: 2024-04-26 08:00
---

[GNU Core Utilities](https://www.gnu.org/software/coreutils/)には[BLAKE2](https://www.blake2.net/)チェックサムを計算と検証できる`b2sum`コマンドが含まれています。
BLAKE2は主に64バイトのハッシュ値を出力するBLAKE2bと、32バイトのハッシュ値を出力するBLAKE2sの2つに分けられますが、このコマンドが対応しているのは前者です。

## BLAKE2の特徴

ホームページによると、BLAKE2には主に以下のような特徴があるようです:

- MD5、SHA-1、SHA-2、SHA-3よりも高速に動作する。
- SHA-3と同程度の安全性を備えている。
- [RFC 7693](https://datatracker.ietf.org/doc/html/rfc7693)として標準化されている。

また、BLAKE2には以下のようなバージョンがあります:

- 64ビット環境に最適化されており、1から64バイトの間で任意の長さのハッシュ値を出力できる**BLAKE2b**。
  - 並列処理に対応した**BLAKE2bp**。
- 8から32ビット環境に最適化されており、1から32バイトの間で任意の長さのハッシュ値を出力できる**BLAKE2s**。
  - 並列処理に対応した**BLAKE2sp**。
- 最大で256 GiBまでの任意の長さのハッシュ値を出力できる**BLAKE2x**。

リファレンス実装は[CC0 1.0 全世界](https://creativecommons.org/publicdomain/zero/1.0/deed.ja)、[OpenSSL License](https://www.openssl.org/source/license-openssl-ssleay.txt)または[Apache License 2.0](https://apache.org/licenses/LICENSE-2.0)のいずれかのライセンスの条件に基づいて利用できます。

https://github.com/BLAKE2/BLAKE2

また、BLAKE2は引数に秘密鍵を指定できるのでHMACを使わなくてもメッセージ認証符号を計算できます。

BLAKE2は鍵導出関数の[Argon2](https://datatracker.ietf.org/doc/html/rfc9106)で使用されたり、多くの暗号化ソフトウェアで実装済みであるなど、既に広く利用されているようです。

## 使い方

基本的には`md5sum`や`sha256sum`などと同様の使い方で、これらと[共通のオプション](https://www.gnu.org/software/coreutils/manual/html_node/cksum-common-options.html)を受け付けます。

```text
b2sum [OPTION]... [FILE]...
```

`b2sum`に固有のオプションとしては出力するハッシュ値の長さを変更するための`-l`（`--length`）があります。
BLAKE2bは出力長を1から64バイトの範囲で任意の長さにすることができますが、このオプションでは8の倍数のビット単位でこれを指定できます。

### 例

ハッシュ値を計算する:

```sh
$ echo "Hello, world!" > foo.txt
$ b2sum foo.txt | tee b2sums.txt
80fe13860815f4a018ad5075bfb6844ca24b5963b6064a3b3912240a5824ba34ef71d2e32870af66b1054c94d65436446fff8ca844667de50ef8f700f9234301  foo.txt
```

ハッシュ値を検証する:

```sh
$ b2sum -c b2sums.txt
foo.txt: OK
```

出力長を変更する:

```sh
$ b2sum -l 384 foo.txt
2b15c7d10b118df4501c447f3332c70f21e9a24d36f190dac59417700fcf2786ed334f0b2881b481c0e1e3fd1143c62a  foo.txt
```

## 導入時期

`b2sum`は2016年11月にリリースされた[coreutils-8.26](https://savannah.gnu.org/news/?id=8709)で追加されました。
多くの環境でこれよりも新しいcoreutilsが提供されているので、既に利用できる場合が殆どだと思います。

:::details Repology
[![Packaging status](https://repology.org/badge/vertical-allrepos/coreutils.svg?columns=3)](https://repology.org/project/coreutils/versions)
:::

## リファレンス実装の同名のコマンド

リファレンス実装も`b2sum`という同じ名前のコマンドを提供しています。
このコマンドはFreeBSDやHomebrewでインストールできるようです。

:::details Repology
[![Packaging status](https://repology.org/badge/vertical-allrepos/b2sum.svg?columns=3)](https://repology.org/project/b2sum/versions)
:::

coreutilsの`b2sum`とは異なり、このコマンドはBLAKE2sなどのアルゴリズムのハッシュ値も計算できるようです。
ハッシュ値の検証はできないようであり、`md5sum`などと共通のオプションも持っていないようです。

これらの環境でもcoreutilsはインストールできるのでcoreutilsの`b2sum`を使うこともできますが、インストールしない場合は`rhash`がBLAKE2bとBLAKE2sのチェックサムの計算と検証ができるのでこれが利用できそうです。

https://github.com/rhash/RHash

## 終わりに

より高速に動作する後継となる暗号学的ハッシュ関数の[BLAKE3](https://github.com/BLAKE3-team/BLAKE3)とチェックサムの計算と検証をする`b3sum`コマンドが既にありますが、現時点ではデフォルトでインストールされるようにはなっていないので、この点では`b2sum`はまだ優位性があると思いました。
