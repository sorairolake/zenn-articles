---
title: "次世代のMarkdownみたいなDjotの話"
emoji: "🗒️"
type: "tech"
topics: ["djot", "markdown", "pandoc"]
published: true
published_at: 2024-03-05 12:00
---

## Djotとは

**Djot**は2022年に登場した軽量マークアップ言語で、[Pandoc](https://pandoc.org/)の作者であり[CommonMark](https://commonmark.org/)の主要開発者でもあるカリフォルニア大学バークレー校の哲学部教授のJohn MacFarlaneさんが開発しています。
Djotの構文は基本的にはCommonMark（Markdown）と似ていますが、CommonMarkの構文の複雑で効率的な解析が難しい部分を修正しています。
また、CommonMarkにない機能として説明リスト、脚注、表、いくつかの種類のインライン書式設定、数式、スマート句読点、どの要素にも適用できる属性、ブロックレベル、インラインレベル、未加工コンテンツ向けの汎用コンテナをサポートしています。

## 新機能

Djotで追加された機能は[GFM](https://github.github.com/gfm/)やPandocの[Markdown](https://pandoc.org/MANUAL.html#pandocs-markdown)で似たような構文でサポートされているものもあります。

### 説明リスト

#### Djot

```text
: 用語

  詳細
```

#### HTML

```html
<dl>
  <dt>用語</dt>
  <dd><p>詳細</p></dd>
</dl>
```

### 脚注

GitHubなどがサポートしている脚注と同じような構文です。

https://github.blog/changelog/2021-09-30-footnotes-now-supported-in-markdown-fields/

### 表

GFMなどの表と同じような構文です。

https://github.github.com/gfm/#tables-extension-

### 書式設定

#### Djot

```text
{+挿入+}

{-削除-}

{=ハイライト=}

b^n^

O~3~
```

#### HTML

```html
<p><ins>挿入</ins></p>
<p><del>削除</del></p>
<p><mark>ハイライト</mark></p>
<p>b<sup>n</sup></p>
<p>O<sub>3</sub></p>
```

### 数式

[LaTeX](https://www.latex-project.org/)の数式を含めることができます。

#### Djot

```text
$`E=mc^{2}`

$$`x=\frac{-b\pm\sqrt{b^{2}-4ac}}{2a}`
```

#### HTML

```html
<p><span class="math inline">\(E=mc^{2}\)</span></p>
<p><span class="math display">\[x=\frac{-b\pm\sqrt{b^{2}-4ac}}{2a}\]</span></p>
```

## Markdownとの比較

Djotの機能の殆どはCommonMark（Markdown）から派生していますが、構文を簡素化したり解析を容易にするためにCommonMarkから削除されたり変更されたりしてる構文がいくつかあります。

### ブロックレベル要素は空白行で区切る必要がある

Djotでは見出しや段落などの[ブロックレベル要素](https://htmlpreview.github.io/?https://github.com/jgm/djot/blob/master/doc/syntax.html#block-syntax)は空白行で区切る必要があります。

以下のテキストを入力した場合:

```text
# 見出し
段落
```

Markdownでは以下のように解釈されます:

```html
<h1>見出し</h1>
<p>段落</p>
```

Djotでは空白行で区切られていないことから見出しが継続していると解釈されて以下のようになります:

```html
<h1>見出し 段落</h1>
```

DjotでMarkdownと同じ解釈をする場合は以下のように見出しと段落を空白行で区切る必要があります:

```text
# 見出し

段落
```

### 見出し

Djotには`#`を使用する[ATX](https://spec.commonmark.org/0.31.2/#atx-headings)形式の見出しだけがあります。
`=`か`-`を使用する[Setext](https://spec.commonmark.org/0.31.2/#setext-headings)形式の見出しはありません。

### コードブロック

インデントによるコードブロックはなく、3つ以上のバッククォート（`` ` ``）で囲むコードブロックだけがあります。

### 強調

Markdownでは`_`か`*`が1つの場合は強調で2つの場合は強い強調でしたが、Djotでは記号の個数ではなく種類で表すように変更されており、1つの`_`で囲まれている場合は強調で`*`で囲まれている場合は強い強調になります。
日本語のようにわかち書きをしない場合でもこれらの記号は1つだけで機能します。

#### Markdown

```md:index.md
_強調_ **強い強調**
```

#### 等しいDjot

```text:index.dj
_強調_ *強い強調*
```

### 改行

Markdownでは強制的に改行したい場合は行末に2つのスペースを挿入しましたが、Djotでは行末に`\`を挿入すると強制的に改行されるように変更されています。

## 実装

Djotは既にいくつかのプログラミング言語で実装されています。
また、Pandocはバージョン3.1.12からDjotの入出力に対応しています[^1]。

### Djot.lua

オリジナルのリファレンス実装で[Lua](https://www.lua.org/)で書かれています。
スクリプト言語で書かれていますがDjotが効率的に解析できるように設計されているので非常に高速に処理することができます。
現在はdjot.jsの開発に重点が置かれているので最新の構文変更に対応していない可能性があります。

https://github.com/jgm/djot.lua

### djot.js

[TypeScript](https://www.typescriptlang.org/)で書かれたオリジナルのリファレンス実装の再実装で、現在はこちらの開発に重点が置かれています。

https://github.com/jgm/djot.js

### Djota

Prologによる実装です。

https://github.com/aarroyoc/djota

### Jotdown

[Rust](https://www.rust-lang.org/)のライブラリとして実装されているプル・パーサーです。

https://github.com/hellux/jotdown

### godjot

[Go](https://go.dev/)で書かれたパーサーです。

https://github.com/sivukhin/godjot

### djoths

[Haskell](https://www.haskell.org/)で書かれたパーサーです。
Pandocはこれを使用しています。

https://github.com/jgm/djoths

## 参考文献

- <https://djot.net/>
- [Djot syntax reference](https://htmlpreview.github.io/?https://github.com/jgm/djot/blob/master/doc/syntax.html)
- [Quick Start for Markdown users](https://github.com/jgm/djot/blob/main/doc/quickstart-for-markdown-users.md)

[^1]: <https://pandoc.org/releases.html#pandoc-3.1.12-2024-02-14>
