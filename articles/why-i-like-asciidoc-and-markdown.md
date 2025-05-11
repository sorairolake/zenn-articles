---
title: "AsciiDocとMarkdownが好きです"
emoji: "📝"
type: "idea"
topics: ["asciidoc", "markdown", "ポエム"]
published: true
published_at: 2025-05-12 07:00
---

## はじめに

私は軽量マークアップ言語として[AsciiDoc](https://asciidoc.org/)が好きです。
また、AsciiDocの次に[Markdown](https://daringfireball.net/projects/markdown/)（[CommonMark](https://commonmark.org/)）が好きです。
この記事ではその理由について述べたいと思います。

:::message
個人的な意見です。
:::

## AsciiDocが好きな理由

### 1. 表現力が高い

AsciiDocでは[説明リスト](https://docs.asciidoctor.org/asciidoc/latest/lists/description/)（定義リスト）、[脚注](https://docs.asciidoctor.org/asciidoc/latest/macros/footnote/)、[表](https://docs.asciidoctor.org/asciidoc/latest/tables/build-a-basic-table/)、[数式](https://docs.asciidoctor.org/asciidoc/latest/stem/)、[相互参照](https://docs.asciidoctor.org/asciidoc/latest/macros/xref/)、[アラート](https://docs.asciidoctor.org/asciidoc/latest/blocks/admonitions/)、[目次の自動生成](https://docs.asciidoctor.org/asciidoc/latest/toc/)、[他のファイルの内容の展開](https://docs.asciidoctor.org/asciidoc/latest/directives/include/)などの豊富な機能が言語の標準機能として利用できます。
個人的に説明リストや`include`ディレクティブはよく使うのでこれが言語の標準機能として利用できるのはとても便利です。

AsciiDocは機能が豊富な分Markdownよりも構文が複雑ですが、[GFM](https://github.github.com/gfm/)や[PHP Markdown Extra](https://michelf.ca/projects/php-markdown/extra/)などの拡張機能を使って書いた文書のような比較的単純な構造のものなら可読性はMarkdownと同じくらいだと思います[^asciidoc-vs-markdown]。

### 2. 方言が少ない

AsciiDocの主な処理系はオリジナルの[AsciiDoc.py](https://asciidoc-py.github.io/)と、現在の公式な言語仕様を定義している[Asciidoctor](https://asciidoctor.org/)の2つです。
AsciiDoc.pyからAsciidoctorで改訂された構文もありますが、AsciidoctorにAsciiDoc.py互換モードもあるのでMarkdownのように方言で困ることは少ないです。
また、Asciidoctorのドキュメントに構文を拡張する方法の例が載っているので[^asciidoctor-extensions]、互換性のない方言が乱立する事態にはならないと思います。

## Markdownが好きな理由

### 1. 構文がシンプル

MarkdownはAsciiDocと比べると構文がシンプルです。
マークアップの種類が少ないので書くときにどの要素を使うか悩まないですみます。
また、複雑な構造が書きにくいことから文書の構造が自然と単純になると思います。

Markdownは表現力が低いと言われますが、メモなどのシンプルな文書を書くのには十分だと思います。

### 2. 処理系・対応サービスが豊富

Markdownの処理系は様々な言語で実装されており、対応サービスも豊富です。
GitHubなど一部のサービスはMarkdownとAsciiDocの両方をレンダリングできますが、多くのサービスではMarkdownだけに対応していることが多いです。

いくつかのプログラミング言語ではドキュメンテーションコメントをMarkdownで書くことができます。

- [Dart](https://dart.dev/effective-dart/documentation#markdown)
- [Julia](https://docs.julialang.org/en/v1/manual/documentation/#Writing-Documentation)
- [Kotlin](https://kotlinlang.org/docs/kotlin-doc.html)
- [Rust](https://doc.rust-lang.org/rustdoc/how-to-write-documentation.html#markdown)
- [Swift](https://www.swift.org/documentation/docc/)

Markdownはフォーマッタや静的解析ツールなどのエコシステムも充実しており、Markdown向けのエディタも数多くあるので書きやすく文書の管理もしやすいように感じます。

## 個人的な使い分け

### AsciiDoc

AsciiDocは複雑な構造の文書やmanページを書くときに使っています。
manページはMarkdownと[Pandoc](https://pandoc.org/)を使っても書けますが、より綺麗に構造化できるのでAsciiDocを使っています。

https://docs.asciidoctor.org/asciidoctor/latest/manpage-backend/

また、GitHubなどのAsciiDocに対応しているサービスでは表現力が少し高いMarkdownみたいな感覚で使えるのでMarkdownより優先して使ってます。

### Markdown

Markdownはメモのような短時間で書きたい文書や単純な構造で十分なときに使っています。
<https://crates.io/>や<https://pkg.go.dev/>はMarkdownはレンダリングできますがAsciiDocはできないので`README`ファイルはMarkdownで書くことが多いです。

## 終わりに

1つの言語だけを使うのではなく、表現力は高いが人気の低いAsciiDocと表現力は低いが対応環境の多いMarkdownを文書の複雑さや用途によって使い分けるのが良いと思いました。

[^asciidoc-vs-markdown]: <https://docs.asciidoctor.org/asciidoc/latest/asciidoc-vs-markdown/>。

[^asciidoctor-extensions]: <https://docs.asciidoctor.org/asciidoctor/latest/extensions/>。
