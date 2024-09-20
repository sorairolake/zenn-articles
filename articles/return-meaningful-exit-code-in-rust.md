---
title: "Rust製コマンドで意味付けされた終了ステータスを返す"
emoji: "🦀"
type: "tech"
topics: ["api", "cli", "rust"]
published: true
published_at: 2024-09-21 08:00
---

## はじめに

[Rust](https://www.rust-lang.org/)で[`<sysexits.h>`](https://man.openbsd.org/sysexits)で定義されている終了ステータスを使えるようにするクレートを開発しているので紹介します。

https://github.com/sorairolake/sysexits-rs

## `<sysexits.h>`とは

`<sysexits.h>`はBSD系に由来する定義付けされた終了ステータスです。
`64`から`78`までの終了ステータスの意味が定義されています。

https://github.com/freebsd/freebsd-src/blob/9046ecff409c45205aad34ef8d959d79dd20cf8f/include/sysexits.h#L35-L111

## `sysexits`クレートについて

`sysexits`は`<sysexits.h>`で定義されている終了ステータスを使えるようにするクレートです。
[`Termination`](https://doc.rust-lang.org/std/process/trait.Termination.html)トレイトを実装しているので`main`関数の戻り値として利用できます。

`<sysexits.h>`では終了ステータスは定数として定義されていますが、`sysexits`クレートでは列挙型として定義しています。

https://github.com/sorairolake/sysexits-rs/blob/e215e3d292d2f5721c6c9924ac4d84b041b8f607/src/exit_code.rs#L20-L217

メソッドとしては終了ステータスが成功を表すときに`true`を返す[`ExitCode::is_success`](https://docs.rs/sysexits/0.8.1/sysexits/enum.ExitCode.html#method.is_success)メソッド、失敗を表すときに`true`を返す[`ExitCode::is_failure`](https://docs.rs/sysexits/0.8.1/sysexits/enum.ExitCode.html#method.is_failure)メソッド、指定した終了ステータスでプロセスを終了する[`ExitCode::exit`](https://docs.rs/sysexits/0.8.1/sysexits/enum.ExitCode.html#method.exit)メソッドを実装しています。

```rust:is_success.rs
assert_eq!(ExitCode::Ok.is_success(), true);
assert_eq!(ExitCode::Usage.is_success(), false);
```

```rust:is_failure.rs
assert_eq!(ExitCode::Ok.is_failure(), false);
assert_eq!(ExitCode::Usage.is_failure(), true);
```

```rust:exit.rs
fn main() {
    ExitCode::Ok.exit();
}
```

また、[`From`](https://doc.rust-lang.org/std/convert/trait.From.html)による終了ステータスのプリミティブ整数型への変換、[`io::Error`](https://doc.rust-lang.org/std/io/struct.Error.html)などからの終了ステータスへの変換を実装しています。

## 使い方

前述の通り、`sysexits`クレートは`Termination`トレイトを実装しているので`main`関数の戻り値として利用できます。

```rust:main.rs
use std::str;

use sysexits::ExitCode;

fn main() -> ExitCode {
    let bytes = [0xf0, 0x9f, 0x92, 0x96];
    match str::from_utf8(&bytes) {
        Ok(string) => {
            println!("{string}");
            ExitCode::Ok
        }
        Err(err) => {
            eprintln!("{err}");
            ExitCode::DataErr
        }
    }
}
```

`<sysexits.h>`で定義されていない終了ステータスも返したいときは、`sysexits::ExitCode`を[`std::process::ExitCode`](https://doc.rust-lang.org/std/process/struct.ExitCode.html)に変換します。

https://github.com/sorairolake/sysexits-rs/blob/e215e3d292d2f5721c6c9924ac4d84b041b8f607/examples/cat.rs#L16-L59

## 終わりに

Rustで`<sysexits.h>`で定義されている終了ステータスを使えるようにする`sysexits`クレートを紹介しました。

詳しい使い方については以下を参照して下さい。

https://docs.rs/sysexits
