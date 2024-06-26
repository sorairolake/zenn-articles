---
title: "コマンドラインでリンク切れのシンボリックリンクを探す"
emoji: "🔍"
type: "tech"
topics: ["cli"]
published: true
published_at: 2024-04-17 07:30
---

Unix系のシンボリックリンクはファイルやディレクトリへのパスだけを保存しているので、これらを削除や改名や移動してもそれを追従しません。
ファイルを改名や移動をしたのにシンボリックリンクの修正を忘れたときに以下のコマンドが便利だったので記事にします。

## find

カレントディレクトリ以下のリンク切れは以下のいずれかで見つかります。

```sh
find . -xtype l

# または
find -L . -type l

# または
find . -follow -type l
```

注意する点は引数の指定順です。
`find`は引数を`find [オプション] [パス] [評価式]`の順番で指定する必要があります。
上の例では`-L`はオプション、`-follow`と`-type l`と`-xtype l`は評価式です。
`-L`と`-follow`は効果は同様ですが指摘できる位置が異なります。
従って、`find -xtype l .`は実行しても失敗します。

`-xtype`はGNU版だけで利用でき、`-follow`は非推奨なことを考えると、`find -L . -type l`を使うのが一番良さそうです。

## fd

[`fd`](https://github.com/sharkdp/fd)でリンク切れを探すには以下のようにします。

```sh
# カレントディレクトリ以下
fd -L -t symlink

# 指定ディレクトリ以下
fd --follow --type symlink . ./src/
```

`find`と異なり`-L`は単純に`--follow`の短い形式です。
書式も`fd [オプション] [パターン] [パス]`なので`find`ほどオプションの指定位置や順序を気にしなくてよさそうです。

## 終わりに

`find`は殆どの環境でデフォルトでインストールされますが、実装間のオプションの有無などの違いや引数の位置や順序など気にすべきことが色々と多く大変なので、インストールできるなら`fd`を使う方が色々と楽だと思いました。
