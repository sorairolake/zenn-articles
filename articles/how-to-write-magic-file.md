---
title: "fileコマンドのmagicファイルの書き方"
emoji: "📝"
type: "tech"
topics: ["cli", "linux", "mac", "shell", "unix"]
published: true
published_at: 2024-12-10 07:00
---

## はじめに

この記事では、[`file(1)`](https://manpages.debian.org/bookworm/manpages-ja/file.1.ja.html)コマンドがファイルフォーマットを識別するために使うmagicファイル（`/usr/share/file/misc/magic`などに置かれる）の書き方について説明します。
これにより、独自のファイルフォーマットや<https://github.com/file/file>に含まれていないファイルフォーマットを`file`コマンドで識別できるようになります。

## 仕様

magicファイルの各行は以下のような形式になっています。

```text
<オフセット> <データ型> <テスト> <メッセージ>
```

以下の例では、ファイルの先頭4バイトがリトルエンディアンで`0x9AA2D903`かつその次の4バイトがリトルエンディアンで`0xB54BFB67`のときに「KDBX」というメッセージを表示します。

```text
0  lelong 0x9AA2D903
>4 lelong 0xB54BFB67 KDBX
```

これはKeePass 2.xの[データベースファイル](https://keepass.info/help/kb/kdbx.html)（`.kdbx`）の先頭8バイトと一致します。
2行目の`>`はテストのレベルを表し、この場合は1行目のテストが成功した場合に2行目のテストが実行されます。

## 例

例として、[lzip](https://www.nongnu.org/lzip/)ファイルを`file`コマンドで識別するためのmagicファイルを書いてみます。

lzipファイルの仕様は以下にあります。

https://www.nongnu.org/lzip/manual/lzip_manual.html#File-format

表にすると以下のようになります。

| オフセット | バイト数 | 説明                   |
| ---------- | -------- | ---------------------- |
| $0$        | $4$      | マジックナンバー       |
| $4$        | $1$      | バージョン番号         |
| $5$        | $1$      | 符号化された辞書サイズ |
| $6$        | $n$      | LZMAストリーム         |
| $6 + n$    | $4$      | 圧縮前のデータのCRC-32 |
| $10 + n$   | $8$      | 圧縮前のデータサイズ   |
| $18 + n$   | $8$      | メンバーの合計サイズ   |

以下の例は、ファイルが「LZIP」で始まる場合に、マジックナンバー、バージョン番号、圧縮前のデータサイズ、メンバーの合計サイズを表示します。

```text:lzip.magic
0     string  LZIP lzip compressed data
>4    ubyte   x    - version %u
>4    ubyte   1
>>-16 ulequad x    \b, uncompressed size %llu bytes
>>-8  ulequad x    \b, member size %llu bytes
```

1行目はファイルが「LZIP」という文字列で始まるかをテストし、成功した場合に「lzip compressed data」という文字列を表示します。
以降の行のテストはこのテストが成功した場合に実行されます。

2行目は4バイト目を符号なし1バイト値としてテストします。
`x`はどんな値にもマッチするので、常に`- version %u`という文字列を表示します。
`%u`は[`printf(3)`](https://manpages.debian.org/bookworm/manpages-ja-dev/printf.3.ja.html)の書式指定子です。

3行目は4バイト目を符号なし1バイト値として解釈したときに`1`と一致するかテストします。
以降の行のテストはこのテストが成功した場合に実行されます。

4行目はファイルの末尾から先頭方向に16バイトの位置からの8バイトを符号なしリトルエンディアンとして解釈してテストします。

5行目はファイルの末尾8バイトを符号なしリトルエンディアンとして解釈してテストします。

### 使い方

デフォルトでは、`file`コマンドは`/usr/share/file/misc/magic.mgc`から情報を読み込み、これがない場合は`/usr/share/file/misc/magic`から読み込みます。
また、`$HOME/.magic.mgc`か`$HOME/.magic`が存在する場合には、これからも情報を読み込みます。

`-m`オプションを使うと指定したファイルから情報を読み込むので、独自のmagicファイルの場合にはこの方法が一般的かと思います。

```sh
$ file -m ./lzip.magic ./test.txt.lz
./test.txt.lz: lzip compressed data - version 1, uncompressed size 36388 bytes, member size 7376 bytes
```

`lzip`コマンドの出力と同じ内容となっているので、想定通りに解釈できていることが確認できます。

```sh
$ lzip -tvvv ./test.txt.lz
  ./test.txt.lz:  4.933:1, 20.27% ratio, 79.73% saved.     36388 out,     7376 in. ok
```

マジックナンバーが「LZIP」でない場合に一行目のテストが失敗することが確認できます。

```sh
$ lzip -t ./fox_bm.lz
lzip: ./fox_bm.lz: Bad magic number (file not in lzip format).
$ file -m ./lzip.magic ./fox_bm.lz
./fox_bm.lz: data
```

バージョン番号が`1`以外のときは3行目のテストが失敗して以降の行のテストが実行されないことが確認できます。

```sh
$ lzip -t ./fox_v2.lz
  ./fox_v2.lz: Version 2 member format not supported.
$ file -m ./lzip.magic ./fox_v2.lz
./fox_v2.lz: lzip compressed data - version 2
```

なお、`file`コマンドはデフォルトでlzipファイルに対応しているので、実際には独自にmagicファイルを書かなくても識別できます。

https://github.com/file/file/blob/ef18b1218393210ae7a7f83c82d69f82c62a3941/magic/Magdir/compress#L166-L170

## 参考文献

- [`magic(5)`](https://manpages.debian.org/bookworm/libmagic1/magic.5.en.html)

## 終わりに

magicファイルの書き方を紹介しました。
独自にmagicファイルを書くことで`file`コマンドがデフォルトで対応していないファイルフォーマットでも識別できるようになって便利なので、一度書いてみてはどうでしょうか。
