---
title: "ripgrepの結果をページャーでいい感じに表示する"
emoji: "🔎"
type: "tech"
topics: ["cli", "rust"]
published: true
---

## はじめに

[ripgrep](https://github.com/BurntSushi/ripgrep)（`rg`）で検索結果が大量にある場合、出力をページャーに渡すことがあると思いますが、そのまま渡しただけでは結果が分かりにくいと思います。

```sh
rg "foo" | bat
rg "foo" | less
```

![表示結果](/images/display-ripgrep-result-with-pager/rg-ugly-output.webp)

この記事は、ripgrepの結果をページャーでいい感じに表示できないか調べた結果をまとめたものです。

以下の例では、<https://github.com/rust-lang/rust>で「foo」という文字列を検索します。

```sh
$ git rev-parse HEAD
ff7906bfe1ed264bf9c4d3abe1940e357b7e61dd
```

## `rg -p`

`rg`を`-p`（`--pretty`）オプションを付けて実行するとカラー出力、見出し、行番号の表示が常に有効になります。
このオプションを指定した出力を[`bat`](https://github.com/sharkdp/bat)や`less -R`に渡すことでいい感じに表示できます。

```sh
rg -p "foo" | bat
rg -p "foo" | less -R
```

![表示結果](/images/display-ripgrep-result-with-pager/rg-with-bat.webp)

## `batgrep`

<https://github.com/eth-p/bat-extras>の`batgrep`を使うことでもいい感じに表示できます。

```sh
batgrep "foo"
```

![表示結果](/images/display-ripgrep-result-with-pager/batgrep.webp)

## `delta`

`rg`を`--json`オプションを付けて実行した結果を[`delta`](https://github.com/dandavison/delta)に渡すことでもいい感じに表示できます。

```sh
rg --json "foo" | delta
```

![表示結果](/images/display-ripgrep-result-with-pager/rg-with-delta.webp)

https://dandavison.github.io/delta/grep.html

## 終わりに

`rg`の結果が大量にあるときにページャーでいい感じに表示する方法を知らなかったので、不便に感じていました。
今回調べた方法でこの問題が解決できそうなので、今後はこれらを活用したいです。
