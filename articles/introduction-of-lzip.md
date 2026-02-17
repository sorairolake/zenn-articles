---
title: "LZMAを使うもう一つの圧縮データフォーマット、lzipのはなし"
emoji: "🗜️"
type: "tech"
topics: ["cli", "lzip", "lzma", "xz"]
published: true
published_at: 2024-04-01 08:00
---

最近、XZ Utilsにバックドア（[CVE-2024-3094](https://www.cve.org/CVERecord?id=CVE-2024-3094)）が発見されたことで圧縮データフォーマットのxzも注目を集めていると思います。
この記事では、xzと同じくを使う圧縮データフォーマットの一つであるlzipを紹介します。

## lzipとは

**lzip**は2008年に開発された圧縮データフォーマットです。

https://www.nongnu.org/lzip/

圧縮アルゴリズムとして[7z](https://www.7-zip.org/7z.html)などでも使われているLZMAを採用しています。

lzipは以下のようなLZMAストリームにチェックサムやマジックナンバーなどを追加した単純なコンテナフォーマットをしています。

| マジックナンバー | バージョン番号 | 辞書サイズ | LZMAストリーム | CRC-32  | データサイズ | メンバーサイズ |
| ---------------- | -------------- | ---------- | -------------- | ------- | ------------ | -------------- |
| 4バイト          | 1バイト        | 1バイト    | 可変長         | 4バイト | 8バイト      | 8バイト        |

lzipはデータの整合性とデコーダーの可用性の両方を考慮して、データ共有と長期的なアーカイブ用途向けに設計されています。

## 使い方

lzipは`gzip`や`bzip2`に似たコマンドラインインターフェイス（`lzip`）を提供しています。

```sh
# 圧縮
lzip README.md

# 展開
lzip -d README.md.lz
```

`lzip`は並列処理に対応していませんが、並列処理に対応した`plzip`が提供されています。

https://www.nongnu.org/lzip/plzip.html

`plzip`はlzip 1.4以降と完全に互換性があります。
`plzip`は`lzip`と比べて遥かに高速に圧縮と展開ができますが、圧縮率は僅かに低下します。

その他には、lzip形式のデータを修復するための`lziprecover`や、lzip形式のデータを読み書きするためのC言語のライブラリの`lzlib`などが提供されています。

https://www.nongnu.org/lzip/lziprecover.html

https://www.nongnu.org/lzip/lzlib.html

これらのコマンドは多くのOSの公式リポジトリでパッケージが提供されているので簡単に使い始めることができると思います。

[![Packaging status](https://repology.org/badge/vertical-allrepos/lzip.svg?columns=3)](https://repology.org/project/lzip/versions)

## xzとの違い

lzipとxzはどちらもLZMAを使用しますが、使用しているバージョンが異なります。
lzipはオリジナルのLZMAを使用しますが、xzはLZMA2を使用します。
LZMA2はその名前からオリジナルのLZMAを更新したバージョンのように見えますが、実際には複数のLZMAで圧縮されたデータと非圧縮データが混在しているコンテナフォーマットです。

lzipの作者は、xzが以下の設計上の理由から長期的なアーカイブ用途には不適切であり、データ共有や自由ソフトウェアの配布には推奨できないと主張しています。

1. 実装間の安全な相互運用性が保証されていない。
2. 拡張性には無理があり問題がある。
3. 保護されていないフラグと長さフィールドに対して脆弱。
4. LZMA2はオリジナルのLZMAより安全でなく効率が悪い。
5. 破損の誤検知を増加させる無駄な機能を含んでいる。
6. 末尾のデータに関して一貫性のない挙動を示す。
7. エラー検出の精度がbzip2、gzip、lzipと比べて数倍低い。

### 比較

[GNU Core Utilities 9.5のtarball](https://ftp.gnu.org/gnu/coreutils/coreutils-9.5.tar.gz)を使用して比較しました。

#### 圧縮

| Command                  |       Mean [s] | Min [s] | Max [s] |    Relative |
| :----------------------- | -------------: | ------: | ------: | ----------: |
| `xz coreutils-9.5.tar`   | 10.587 ± 0.163 |  10.246 |  10.789 |        1.00 |
| `lzip coreutils-9.5.tar` | 21.176 ± 0.130 |  20.969 |  21.384 | 2.00 ± 0.03 |

#### 展開

| Command                        |    Mean [ms] | Min [ms] | Max [ms] |    Relative |
| :----------------------------- | -----------: | -------: | -------: | ----------: |
| `xz -d coreutils-9.5.tar.xz`   | 196.2 ± 19.7 |    175.2 |    248.5 |        1.00 |
| `lzip -d coreutils-9.5.tar.lz` |  624.7 ± 3.2 |    619.2 |    629.8 | 3.18 ± 0.32 |

#### ファイルサイズ

| フォーマット |   バイト数 | データ圧縮比 |
| :----------- | ---------: | -----------: |
| オリジナル   | 61,214,720 |        1.000 |
| lzip         |  6,443,423 |        9.500 |
| xz           |  6,482,572 |        9.443 |

#### バージョン

| コマンド | バージョン |
| :------- | ---------: |
| `lzip`   |     1.24.1 |
| `xz`     |      5.6.1 |

## ソフトウェアの対応

GNU tarとbsdtarはどちらもlzipに対応しています。

```sh
# 圧縮
tar -acf linux-6.8.2.tar.lz linux-6.8.2

# 展開
tar -xf linux-6.8.2.tar.lz
```

`xz`は圧縮は対応していませんが、展開は対応しています[^1]。

## 終わりに

LZMAを使うもう一つの圧縮データフォーマットのlzipを紹介しました。
xzと比較した際には利点と欠点の両方があるように思うので、適宜使い分けるのが良さそうです。

## 参考文献

- [Xz format inadequate for long-term archiving](https://www.nongnu.org/lzip/xz_inadequate.html)

[^1]: <https://manpages.debian.org/bookworm/xz-utils/xz.1.en.html#DESCRIPTION>
