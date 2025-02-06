---
title: "Rustの標準ライブラリで乱数生成ができるようになるかもしれない"
emoji: "🎲"
type: "tech"
topics: ["rust"]
published: true
---

現在のRustの標準ライブラリには実験的なモジュールとして[`std::random`](https://doc.rust-lang.org/std/random/index.html)があります。

このモジュールには以下のアイテムが含まれています。

- [`DefaultRandomSource`](https://doc.rust-lang.org/std/random/struct.DefaultRandomSource.html)構造体
- [`Random`](https://doc.rust-lang.org/std/random/trait.Random.html)トレイト
- [`RandomSource`](https://doc.rust-lang.org/std/random/trait.RandomSource.html)トレイト
- [`random`](https://doc.rust-lang.org/std/random/fn.random.html)関数

`Random`トレイトと`RandomSource`トレイトは`no_std`環境でも利用できます。

`DefaultRandomSource`構造体は[`getrandom`](https://www.man7.org/linux/man-pages/man2/getrandom.2.html)や[`ProcessPrng`](https://learn.microsoft.com/en-us/windows/win32/seccng/processprng)などのシステムの乱数生成器を表します。
`Random`トレイトは指定したデータ型の乱数を取得するためのトレイトです。
現在は`i32`や`u8`などのプリミティブ整数型と`bool`に対して実装されています。
`RandomSource`トレイトは乱数性の源を表し、現在は`DefaultRandomSource`構造体に対して実装されています。
`random`関数は`DefaultRandomSource`構造体から乱数を生成します。

このモジュールが安定化された場合、[`rand`](https://crates.io/crates/rand)クレートを使わないで標準ライブラリだけで乱数生成ができるようになると思います。
ただし、このモジュールが提供するのは基本的な機能だけなようなので、異なる乱数生成器を使いたいなどより強力な機能が必要なときは`rand`クレートは引き続き有用だと思います。

## 使い方

`random`モジュールは実験的なので利用するには`random`機能を有効にする必要があります。

```rust:main.rs
#![feature(random)]

fn main() {
    let v: i32 = std::random::random();
    println!("{v}");
}
```

これは以下のような結果を得られます。

```sh
$ cargo +nightly run
980775249
$ cargo +nightly run
-1575229708
```

## 参考文献

- <https://github.com/rust-lang/rust/issues/130703>
