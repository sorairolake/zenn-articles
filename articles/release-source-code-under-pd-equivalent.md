---
title: "ソースコードをパブリックドメインと同等の条件で公開するまで"
emoji: "📄"
type: "tech"
topics: ["creativecommons", "license"]
published: true
---

## はじめに

基本的に、オープンソースライセンス（自由ソフトウェアライセンス）では著作権表示を保持することが自由な利用の条件であることが多く、パブリックドメインとは異なります。
この記事では、著作物の要件を満たしているソースコードをパブリックドメインと同等の条件で公開する方法について述べようと思います。

オープンソースやパブリックドメインについては以下を参照してください。

https://shujisado.com/2024/01/17/opensource-and-poublicdomain/

https://ja.wikipedia.org/wiki/%E3%83%91%E3%83%96%E3%83%AA%E3%83%83%E3%82%AF%E3%83%89%E3%83%A1%E3%82%A4%E3%83%B3

https://ja.wikipedia.org/wiki/%E3%83%91%E3%83%96%E3%83%AA%E3%83%83%E3%82%AF%E3%83%89%E3%83%A1%E3%82%A4%E3%83%B3%E3%82%BD%E3%83%95%E3%83%88%E3%82%A6%E3%82%A7%E3%82%A2

## 著作権を放棄する方法

著作物の要件を満たしているソースコードをパブリックドメインにすることは、各法域により法の内容が異なることなどから法的に簡単なことではありません。
したがって、以下のような確立されたパブリックドメインと同等のライセンスを使うのが良いと思います。

### 1. CC0

https://creativecommons.org/publicdomain/zero/1.0/deed.ja

CC0について、GNUプロジェクトでは以下のように説明されています[^gnu-cc0]。

> CC0はクリエイティブ・コモンズのパブリック・ドメインの献呈です。
> CC0でリリースされた作品は、法律で認められる可能な限り最大限のパブリック・ドメインの献呈です。
> なにかの理由でこれができない場合、CC0はゆるい寛容なライセンスも予備として用意しています。

この法的ツールはフリーソフトウェア財団によって自由ソフトウェアライセンスとして承認されており、ソースコードをパブリックドメインで公開する方法として推奨しています。

### 2. Unlicense

https://unlicense.org/

Unlicenseについて、GNUプロジェクトでは以下のように説明されています[^gnu-unlicense]。

> Unlicenseはパブリック・ドメインの献呈です。
> Unlicenseでリリースされた作品は、法律の許す範囲で最大限、パブリック・ドメインに献呈され、この献呈が不十分な場合にカバーされる追加のゆるいライセンスも付いています。

このライセンスはフリーソフトウェア財団によって自由ソフトウェアライセンスとして承認されていますが、ソースコードをパブリックドメインで公開する方法としては代わりにCC0を使うことを推奨しています。
また、OSIによってオープンソースライセンスとして承認されています。

### 3. WTFPL

https://www.wtfpl.net/

WTFPLについて、GNUプロジェクトでは以下のように説明されています[^gnu-wtfpl]。

> これは、ゆるい寛容なコピーレフトでない自由ソフトウェアライセンスで、GNU GPLと両立します。

このライセンスはフリーソフトウェア財団によって自由ソフトウェアライセンスとして承認されています。

## やり方

以下の手順を行うことでソースコードをパブリックドメインと同等の条件で公開できます。

### ライセンスのコピーを追加する

ライセンスの原文のコピーを`LICENSE`などのファイル名で追加します。
FSFEの[`reuse`](https://github.com/fsfe/reuse-tool)というツールを使うとSPDXライセンス識別子に基づいてライセンスの原文をダウンロードして簡単に追加できます。

```sh
$ reuse download CC0-1.0
Successfully downloaded LICENSES/CC0-1.0.txt.
```

### `README`にライセンスの情報を書く

必要ではないですが、`README.md`などにそのプロジェクトのライセンスがなにかを書いておくと利用者にとってわかりやすいと思います。

### 各ファイルにライセンス告知を追加する

これも必要ではないですが、各ファイルにライセンス告知を追加しておくと利用者にとってわかりやすいと思います。
特に、ライブラリのソースコードは`CC0-1.0`で公開してコマンドラインのソースコードは`Apache-2.0 OR MIT`で公開するのようなファイルによってライセンスが異なる場合にこれは便利です。

これも`reuse`を使うことで簡単に行うことができます。

```rust:main.rs
fn main() {
    println!("Hello, world!");
}
```

```sh
$ reuse annotate -c "John Doe" -l CC0-1.0 -y 2025 src/main.rs
Successfully changed header of src/main.rs
```

```rust:main.rs
// SPDX-FileCopyrightText: 2025 John Doe
//
// SPDX-License-Identifier: CC0-1.0

fn main() {
    println!("Hello, world!");
}
```

## 終わりに

後はGitHubなどの公開リポジトリにプッシュすれば著作物の要件を満たしているソースコードをパブリックドメインと同等の条件で公開できます。

[^gnu-cc0]: <https://www.gnu.org/licenses/license-list.html#CC0>。

[^gnu-unlicense]: <https://www.gnu.org/licenses/license-list.html#Unlicense>。

[^gnu-wtfpl]: <https://www.gnu.org/licenses/license-list.html#WTFPL>。
