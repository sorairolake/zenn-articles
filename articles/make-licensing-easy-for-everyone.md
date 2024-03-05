---
title: "人にもコンピュータにも優しいライセンシング「REUSE」"
emoji: "📄"
type: "tech"
topics: ["license", "oss"]
published: true
published_at: 2024-03-06 11:00
---

## REUSEとは

**REUSE**はFree Software Foundation Europe（FSFE）が開始した人にもコンピュータにも優しいライセンシングのための仕様です。

https://reuse.software/

REUSEを利用することで各ファイルのライセンスや著作権者を簡単に把握できるようになり、OSSの再利用が簡単になります。

## 使い方

プロジェクトをREUSEに準拠させるには以下の手順を実行します。

1. ライセンスを選択する
2. 各ファイルに著作権表示とライセンス情報を追加する

例として、以下のようなプロジェクトを使用します。

```text
.
├── .gitignore
├── assets
│  └── screenshot.webp
├── Cargo.lock
├── Cargo.toml
├── README.md
└── src
   └── main.rs
```

### ライセンスを選択する

ライセンスを選択するには、プロジェクトのルートディレクトリに`LICENSES`というディレクトリを作成し、その中にライセンスファイルを追加します。
ライセンスファイルのファイル名はSPDX License Identifierに続けて拡張子を付けたものにする必要があります。
例えば、GNU General Public License v3.0またはそれ以降の場合は`GPL-3.0-or-later.txt`として、MIT Licenseの場合は`MIT.txt`とする必要があります。

### 各ファイルに著作権表示とライセンス情報を追加する

各ファイルに著作権表示とライセンス情報を追加するには、以下のようにファイルにコメントを追加します。

```rust:src/main.rs
// SPDX-FileCopyrightText: 2024 John Doe
//
// SPDX-License-Identifier: CC0-1.0

fn main() {
    println!("Hello, world!");
}
```

画像ファイルやJSONファイルのようにコメントの追加が難しい場合は、ファイル名に`.license`という拡張子を付けたファイルを作成して、そのファイルに著作権表示とライセンス情報を追加します。

これらの手順を実行した後のプロジェクトの構成は以下のようになります。

```text
.
├── .gitignore
├── assets
│  ├── screenshot.webp
│  └── screenshot.webp.license
├── Cargo.lock
├── Cargo.lock.license
├── Cargo.toml
├── LICENSES
│  └── CC0-1.0.txt
├── README.md
└── src
   └── main.rs
```

## reuse-tool

FSFEからプロジェクトをREUSEに準拠させるためのツールが提供されています。

https://github.com/fsfe/reuse-tool

`reuse`はPyPIで公開されており、`pip`を使って簡単にインストールできます。

```sh
pip install reuse
```

### 使い方

#### 著作権表示とライセンス情報を追加する

`reuse annotate`を実行するとファイルに著作権表示とライセンス情報を追加できます。

```sh
reuse annotate -c "John Doe" -l "CC0-1.0" -y "2024" src/main.rs
```

#### プロジェクトがREUSEに準拠しているか確認する

`reuse lint`を実行するとプロジェクトがREUSEに準拠しているか確認できます。

```text
# SUMMARY

* Bad licenses: 0
* Deprecated licenses: 0
* Licenses without file extension: 0
* Missing licenses: 0
* Unused licenses: 0
* Used licenses: CC0-1.0
* Read errors: 0
* files with copyright information: 6 / 6
* files with license information: 6 / 6

Congratulations! Your project is compliant with version 3.0 of the REUSE Specification :-)
```

## 終わりに

最近はSBOM対応などOSSのライセンス把握の難しさが問題となることも多いので、REUSEを利用することはこの問題の解決に有効だと思いました。
