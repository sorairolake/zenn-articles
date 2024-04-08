---
title: "lzipのGo言語実装を開発したはなし"
emoji: "🥳"
type: "tech"
topics: ["cli", "go", "lzip", "lzma"]
published: true
published_at: 2024-04-09 08:00
---

[lzip](https://www.nongnu.org/lzip/)の実装を[Go言語](https://go.dev/)で開発しました。
[pkg.go.dev](https://pkg.go.dev/)で調べた限りだと読み取りに対応した実装はありましたが、書き込みも対応している実装はなさそうだったのが理由です。

## 概要

**lzip-go**はGoによるlzipの実装です。

https://pkg.go.dev/github.com/sorairolake/lzip-go

完全にGoで書かれており（pure Go）、C言語のコードには一切依存していません。
lzip形式で圧縮されたファイルの読み取りと書き込みに対応しています。
APIは標準ライブラリの`compress/gzip`パッケージを参考にしており、LZMAストリームのエンコードとデコードは`github.com/ulikunitz/xz/lzma`を使用しています。

https://pkg.go.dev/compress/gzip

https://pkg.go.dev/github.com/ulikunitz/xz/lzma

lzip形式には現時点でバージョン0と1の2種類が存在しますが、上流のコマンドやライブラリが既にバージョン0に対応していないので、このパッケージもバージョン1だけに対応しています。

## lzipについて

:::details 関連記事
https://zenn.dev/sorairolake/articles/introduction-of-lzip
:::

lzipは2008年に開発された圧縮データフォーマットで、データの整合性とデコーダーの可用性の両方を考慮しており、データ共有と長期的なアーカイブ用途向けに設計されています。
圧縮アルゴリズムとして[7z](https://www.7-zip.org/7z.html)や[xz](<https://ja.wikipedia.org/wiki/Xz_(%E3%83%95%E3%82%A1%E3%82%A4%E3%83%AB%E3%83%95%E3%82%A9%E3%83%BC%E3%83%9E%E3%83%83%E3%83%88)>)でも使われているLZMAを使用します。
使用しているLZMAのバージョンは、lzipはオリジナルのLZMA、xzはLZMA2、7zはオリジナルのLZMAとLZMA2の両方に対応と微妙に異なります。
LZMA2は複数のLZMAで圧縮されたデータと非圧縮データが混在しているコンテナフォーマットです。

lzipは以下のようなLZMAストリームにチェックサムやマジックナンバーなどを追加した単純なコンテナフォーマットをしています。

|                  | オフセット | バイト数 | 説明                                                     |
| ---------------- | ---------- | -------- | -------------------------------------------------------- |
| マジックナンバー | $0$        | $4$      | lzip形式を識別するための文字列（`LZIP`）。               |
| バージョン番号   | $4$        | $1$      | 将来フォーマットを変更する場合に備えたバージョン番号。   |
| 辞書サイズ       | $5$        | $1$      | LZMAの辞書の大きさで、符号化されている。                 |
| LZMAストリーム   | $6$        | $n$      | 「End Of Stream」マーカーで終わるLZMAストリーム。        |
| CRC-32           | $6+n$      | $4$      | 圧縮前のデータのCRC。                                    |
| データサイズ     | $10+n$     | $8$      | 圧縮前のデータの大きさ。                                 |
| メンバーサイズ   | $18+n$     | $8$      | ヘッダーなども含めたファイルの先頭から終端までの大きさ。 |

lzipは上記のような単純なフォーマットなので、他の圧縮データフォーマットと比べて実装するのは簡単だと思います。

## コード例

https://github.com/sorairolake/lzip-go/blob/c406d8f4a57c2145ea72ad84e2c9c822a38aa369/example_test.go

## ツール

lzip形式で圧縮されたファイルの読み取りと書き込みができる単純なコマンドラインユーティリティも開発しました。

https://pkg.go.dev/github.com/sorairolake/lzip-go/cmd/glzip

以下のコマンドでインストールできます。

```sh
go install github.com/sorairolake/lzip-go/cmd/glzip@latest
```

現時点では以下のことができます。

- 複数ファイルを含めた圧縮と展開。
- 結果の標準出力への出力。
- 入力ファイルの維持。
- 辞書サイズの指定。

## 終わりに

lzip自体は前から知っていましたが、最近のXZ Utilsの問題から注目するようになりました。
結果としてGoによる読み書きに対応した実装を開発できたので良かったです。
