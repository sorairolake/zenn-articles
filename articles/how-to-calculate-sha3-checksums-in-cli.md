---
title: "CLIでもSHA-3チェックサムの計算がしたい！"
emoji: "🔏"
type: "tech"
topics: ["cli"]
published: true
published_at: 2024-05-13 08:00
---

MD5やSHA-2の場合は`md5sum`や`sha256sum`などのチェックサムを計算するコマンドがデフォルトでインストールされますが、SHA-3（Keccak）の場合は似たようなコマンドがデフォルトでインストールされることは少ないと思います。
そこで、この目的に使用できるコマンドについて調べてみました。

## OpenSSL/LibreSSL

[OpenSSL](https://www.openssl.org/) 1.1.1以降と[LibreSSL](https://www.libressl.org/) 3.8.0以降はSHA-3をサポートしています。

:::details OpenSSL Repology
[![Packaging status](https://repology.org/badge/vertical-allrepos/openssl.svg?columns=3)](https://repology.org/project/openssl/versions)
:::

:::details LibreSSL Repology
[![Packaging status](https://repology.org/badge/vertical-allrepos/libressl.svg?columns=3)](https://repology.org/project/libressl/versions)
:::

`openssl dgst`コマンドによってチェックサムを計算でき、`-r`オプションを追加することでcoreutilsのフォーマットで出力できます。
SHA-3チェックサムを計算するには`-sha3-{224,256,384,512}`オプションを追加します。

```sh
$ echo "Hello, world!" > foo.txt
$ openssl dgst -sha3-256 -r foo.txt
ae6802d17c07cbe2b677c46decd5c2c28a4a585fedcb813ad8e7cb1469782773 *foo.txt
```

## RHash

[RHash](https://rhash.sourceforge.io/)はバージョン1.3.0からSHA-3をサポートしています。

:::details Repology
[![Packaging status](https://repology.org/badge/vertical-allrepos/rhash.svg?columns=3)](https://repology.org/project/rhash/versions)
:::

SHA-3チェックサムを計算するには`--sha3-{224,256,384,512}`オプションを追加します。

```sh
$ echo "Hello, world!" > foo.txt
$ rhash --sha3-256 foo.txt | tee sha3-256sums.txt
ae6802d17c07cbe2b677c46decd5c2c28a4a585fedcb813ad8e7cb1469782773  foo.txt
```

検証するには`-c`オプションを追加します。

```sh
$ rhash -c sha3-256sums.txt

--( Verifying sha3-256sums.txt )------------------------------------------------
foo.txt                                             OK
--------------------------------------------------------------------------------
Everything OK
```

## uutils coreutils

[uutils coreutils](https://uutils.github.io/coreutils/)の[`hashsum`](https://uutils.github.io/coreutils/docs/utils/hashsum.html)コマンドはSHA-3をサポートしています。

:::details Repology
[![Packaging status](https://repology.org/badge/vertical-allrepos/uutils-coreutils.svg?columns=3)](https://repology.org/project/uutils-coreutils/versions)
:::

SHA-3チェックサムを計算するには`--sha3-{224,256,384,512}`オプションを追加します。
環境によっては`sha3-{224,256,384,512}sum`のコマンド名で実行できるかもしれません。

```sh
$ echo "Hello, world!" > foo.txt
$ hashsum --sha3-256 foo.txt | tee sha3-256sums.txt
# または
$ sha3-256sum foo.txt | tee sha3-256sums.txt
ae6802d17c07cbe2b677c46decd5c2c28a4a585fedcb813ad8e7cb1469782773  foo.txt
```

検証するには`-c`オプションを追加します。

```sh
$ hashsum --sha3-256 -c sha3-256sums.txt
# または
$ sha3-256sum -c sha3-256sums.txt
foo.txt: OK
```

オプションはcoreutilsの[cksumの共通オプション](https://www.gnu.org/software/coreutils/manual/html_node/cksum-common-options.html)の多くが実装されているようです。

## libkeccak/sha3sum

[sha3sum](https://codeberg.org/maandree/sha3sum)はSHA-3チェックサムを計算するコマンドラインユーティリティで、[libkeccak](https://codeberg.org/maandree/libkeccak)を使用しています。

:::details Repology
[![Packaging status](https://repology.org/badge/vertical-allrepos/sha3sum.svg?columns=3)](https://repology.org/project/sha3sum/versions)
:::

出力長に合わせて`sha3-{224,256,384,512}sum`から目的のコマンドを選んで実行します。

```sh
$ echo "Hello, world!" > foo.txt
$ sha3-256sum foo.txt | tee sha3-256sums.txt
ae6802d17c07cbe2b677c46decd5c2c28a4a585fedcb813ad8e7cb1469782773  foo.txt
```

検証するには`-c`オプションを追加します。

```sh
$ sha3-256sum -c sha3-256sums.txt
foo.txt: OK
```

## 所感

計算だけの場合は多くの環境でデフォルトでインストールされる可能性が高いのでOpenSSLが一番簡単に利用できるように思います。
検証もする場合はインストールのしやすさの点ではRHashで、coreutilsとの互換性重視の場合はuutils coreutilsが良いように思います。
