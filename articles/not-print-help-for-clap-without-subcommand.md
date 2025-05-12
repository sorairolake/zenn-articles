---
title: "clapでサブコマンドがないときにヘルプを表示しないようにする"
emoji: "🦀"
type: "tech"
topics: ["clap", "cli", "rust"]
published: true
---

## はじめに

これはRustの[`clap`](https://crates.io/crates/clap)クレートで必須のサブコマンドを指定しなかったときにヘルプメッセージではなくエラーを表示する方法についての記事です。

## 環境

```sh
$ cargo version
cargo 1.86.0 (adf9b6ad1 2025-02-28)
```

```toml:Cargo.toml
[dependencies]
clap = { version = "4.5.38", features = ["derive"] }
```

## 方法

以下は`add`と`remove`というサブコマンドを持つコマンドのコードです。
`command: Command`は必須のサブコマンドを定義しています。

```rust:main.rs
use std::path::PathBuf;

use clap::{Args, Parser, Subcommand};

#[derive(Debug, Parser)]
#[command(version)]
struct Opt {
    #[command(subcommand)]
    command: Command,
}

#[derive(Debug, Subcommand)]
enum Command {
    /// Add file.
    Add(Add),

    /// Remove file.
    Remove(Remove),
}

#[derive(Args, Debug)]
pub struct Add {
    /// File to add.
    file: Option<PathBuf>,
}

#[derive(Args, Debug)]
pub struct Remove {
    /// File to remove.
    file: Option<PathBuf>,
}

fn main() {
    let opt = Opt::parse();
    println!("{opt:?}");
}
```

このコマンドをサブコマンドを指定しないで実行するとヘルプメッセージが表示され非ゼロで終了します。

```sh
$ demo
Usage: demo <COMMAND>

Commands:
  add     Add file
  remove  Remove file
  help    Print this message or the help of the given subcommand(s)

Options:
  -h, --help     Print help
  -V, --version  Print version
```

このコマンドでサブコマンドを指定していない場合にヘルプメッセージではなくサブコマンドが指定されていない旨のエラーメッセージを表示するには、以下のように`arg_required_else_help(false)`を追加します。

```diff rust:main.rs
@@ -3,7 +3,7 @@
 use clap::{Args, Parser, Subcommand};

 #[derive(Debug, Parser)]
-#[command(version)]
+#[command(version, arg_required_else_help(false))]
 struct Opt {
     #[command(subcommand)]
     command: Command,
```

これにより、ヘルプメッセージではなくエラーメッセージが表示されるようになります。

```sh
$ demo
error: 'demo' requires a subcommand but one was not provided
  [subcommands: add, remove, help]

Usage: demo <COMMAND>

For more information, try '--help'.
```

## 解説

Derive APIでサブコマンドが必須の場合にサブコマンドを指定しないとヘルプメッセージが表示される理由は、`arg_required_else_help(true)`が暗黙的に設定されるからです。

https://github.com/clap-rs/clap/blob/6b12a81bafe7b9d013b06981f520ab4c70da5510/CHANGELOG.md?plain=1#L1169

https://github.com/clap-rs/clap/blob/6b12a81bafe7b9d013b06981f520ab4c70da5510/CHANGELOG.md?plain=1#L1609

https://github.com/clap-rs/clap/issues/3280

[`arg_required_else_help`](https://docs.rs/clap/4.5.38/clap/struct.Command.html#method.arg_required_else_help)は引数が存在しない場合にヘルプメッセージを表示して終了するようにするメソッドで、サブコマンドも引数として数えられます。
`arg_required_else_help(false)`を追加することでこの暗黙的な設定を上書きしています。

サブコマンドが必須の場合は`subcommand_required(true)`も暗黙的に設定されます。
[`subcommand_required`](https://docs.rs/clap/4.5.38/clap/struct.Command.html#method.subcommand_required)は実行時にサブコマンドが存在しない場合にエラーメッセージを表示して終了するようにするメソッドです。

## サブコマンドがオプションの場合

以下のように`command: Command`を`command: Option<Command>`に書き換えることでサブコマンドを任意指定にできます。

```diff rust:main.rs
@@ -6,7 +6,7 @@
 #[command(version)]
 struct Opt {
     #[command(subcommand)]
-    command: Command,
+    command: Option<Command>,
 }

 #[derive(Debug, Subcommand)]
```

この場合はサブコマンドを指定していない場合でも正常に終了します。

```sh
$ demo
Opt { command: None }
```

`command: Option<Command>`の場合には`arg_required_else_help(true)`と`subcommand_required(true)`は暗黙的に設定されません。

## 他のオプションが存在する場合

以下のようにこのコマンドに`--quiet`というフラグを追加します。

```diff rust:main.rs
@@ -5,6 +5,10 @@
 #[derive(Debug, Parser)]
 #[command(version)]
 struct Opt {
+    /// Suppress warning messages.
+    #[arg(short, long)]
+    quiet: bool,
+
     #[command(subcommand)]
     command: Command,
 }
```

`arg_required_else_help(false)`を追加せず、サブコマンドは指定しないでフラグを指定しない場合と指定した場合の結果は以下のようになります。

```sh
$ demo
Usage: demo [OPTIONS] <COMMAND>

Commands:
  add     Add file
  remove  Remove file
  help    Print this message or the help of the given subcommand(s)

Options:
  -q, --quiet    Suppress warning messages
  -h, --help     Print help
  -V, --version  Print version
$ demo -q
error: 'demo' requires a subcommand but one was not provided
  [subcommands: add, remove, help]

Usage: demo [OPTIONS] <COMMAND>

For more information, try '--help'.
```

`--quiet`を指定した場合、引数が存在することからヘルプメッセージではなくエラーメッセージが表示されます。

`arg_required_else_help(false)`を追加して、サブコマンドは指定しないでフラグを指定しない場合と指定した場合の結果は以下のようになります。

```sh
$ demo
error: 'demo' requires a subcommand but one was not provided
  [subcommands: add, remove, help]

Usage: demo [OPTIONS] <COMMAND>

For more information, try '--help'.
$ demo -q
error: 'demo' requires a subcommand but one was not provided
  [subcommands: add, remove, help]

Usage: demo [OPTIONS] <COMMAND>

For more information, try '--help'.
```

## 終わりに

個人的には必須のサブコマンドが指定されていない場合はヘルプメッセージではなくエラーメッセージを表示するほうが何が間違っていたのかわかりやすいと思うので、この方法を知ることができて良かったです。
