---
title: "日本の公的機関向けライセンスを軽量マークアップ言語にした"
emoji: "📄"
type: "tech"
topics: ["license"]
published: true
---

日本の政府や地方公共団体などの公的機関向けのライセンスの[公共データ利用規約（第1.0版）](https://www.digital.go.jp/resources/open_data/public_data_license_v1.0)の軽量マークアップ言語版を公開しました。

https://github.com/sorairolake/public-data-license-lml

## 公共データ利用規約とは

公共データ利用規約は2024年7月5日にデジタル庁が定めた日本の政府や地方公共団体などの公的機関のウェブサイトで使用するための利用規約です。
[政府標準利用規約（第2.0版）](https://www.digital.go.jp/assets/contents/node/basic_page/field_ref_resources/f7fde41d-ffca-4b2a-9b25-94b8a701a037/70143e67/20220523_resources_data_betten_03.pdf)の後継利用規約で、引き続き[CC BY 4.0](https://creativecommons.org/licenses/by/4.0/legalcode.ja)と互換性があります。

公共データ利用規約（第1.0版）と政府標準利用規約（第2.0版）の主な違いは以下の通りです[^1]。

- 雛形を各府省が書き換えて利用する方法から、本文は同一の内容を参照して、個別に規定する必要がある部分だけを別紙として規定する方法に変更。
- 地方公共団体での利用も想定した規定に改訂。

## 作った理由

FOSSプロジェクトでライセンスを設定するときにプレーンテキスト形式のライセンスが利用できると便利だと思ったからです。
2024年9月10日現在、公共データ利用規約（第1.0版）は[ウェブテキスト](https://www.digital.go.jp/resources/open_data/public_data_license_v1.0)または[PDF](https://www.digital.go.jp/assets/contents/node/basic_page/field_ref_resources/f7fde41d-ffca-4b2a-9b25-94b8a701a037/24afdf33/20240705_resources_data_outline_05.pdf)として利用できます。
FOSSプロジェクトではリポジトリにライセンスのコピーを含めることが一般的ですが、この用途にはプレーンテキスト形式が適していると思います。
前述の通り、公共データ利用規約（第1.0版）で利用が許諾された著作物はCC BY 4.0に従って利用することもでき、CC BY 4.0は[プレーンテキスト形式](https://creativecommons.org/licenses/by/4.0/legalcode.txt)でも公開されていることからこれを利用することもできますが、公共データ利用規約（第1.0版）を直接設定できると便利だと思いました。

## 利用可能なフォーマット

- [AsciiDoc](https://asciidoc.org/)
- [CommonMark](https://commonmark.org/)
- [Djot](https://djot.net/)
- [Org](https://orgmode.org/)
- [reStructuredText](https://docutils.sourceforge.io/rst.html)

## 作成方法

ウェブテキスト版をHTMLからCommonMark（Markdown）に変換して、それを基にAsciiDocは構文に合うように書き換えて、それ以外は[Pandoc](https://pandoc.org/)で変換の変換と修正によって作成しました。
HTMLに変換したときにウェブテキスト版となるべく同じようなマークアップになるようにはしていますが、完全に一致するわけではないので注意して下さい。

## 変換方法

軽量マークアップ言語で書かれているのでプレーンテキストとしてそのまま利用できますが、[Asciidoctor](https://asciidoctor.org/)やPandocによって他のフォーマットに変換することができます。

```sh
# AsciiDocをHTMLに変換する
asciidoctor PDL-1.0.adoc

# CommonMarkをHTMLに変換する
pandoc -f commonmark -o PDL-1.0.html -s PDL-1.0.md
```
