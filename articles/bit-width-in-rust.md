---
title: "Rustで整数を表すのに必要なビット数を求める"
emoji: "🦀"
type: "tech"
topics: ["rust"]
published: true
---

## はじめに

この記事は、[Rust](https://www.rust-lang.org/)で[Python](https://www.python.org/)の[`int.bit_length()`](https://docs.python.org/ja/3.13/library/stdtypes.html#int.bit_length)のように整数を表すのに必要なビット数を求める方法について書いたものです。

:::message
紹介する方法は主にRust 1.67.0以降で利用できます。
:::

:::message
紹介する方法には間違いがあるかもしれないので、実際に使用する場合には事前に検証することを推奨します。
:::

## 自然数の場合

整数$n$が$n > 0$であるとき、`n.ilog2() + 1`で$n$を表すのに必要なビット数を求めることができます。

```rust
let answer: u8 = 42;
assert_eq!(answer.ilog2() + 1, 6);
```

[`ilog2()`](https://doc.rust-lang.org/std/primitive.i32.html#method.ilog2)は$n \leqq 0$であるときはパニックします。
$n \leqq 0$な可能性があるときは、`Option<T>`を返す[`checked_ilog2()`](https://doc.rust-lang.org/std/primitive.i32.html#method.checked_ilog2)を利用することでパニックを避けることができます。

```rust
let answer: u8 = 42;
assert_eq!(answer.checked_ilog2().map(|n| n + 1), Some(6));
assert!(0_u8.checked_ilog2().is_none());
```

`ilog2`や`checked_ilog2`はRust 1.67.0で安定化されました。
それ以前のバージョンでは、以下のようにその型のビット数（`32`）から[`leading_zeros()`](https://doc.rust-lang.org/std/primitive.u32.html#method.leading_zeros)で得た値を二進数で表現したときの先頭の`0`の数を引くことで同様の結果を求められます。

```rust
let answer: u32 = 42;
let old = 32 - answer.leading_zeros();
let new = answer.ilog2() + 1;
assert_eq!(old, new);
```

`32`というマジックナンバーは、Rust 1.53.0で安定化されたその型のビット数を表す[`BITS`](https://doc.rust-lang.org/std/primitive.u32.html#associatedconstant.BITS)関連定数で置き換えることができます。

$n = 0$も含めた全ての符号無し整数で値を表すのに必要なビット数は、以下の方法で求めることができます。

```rust
let n = u32::MIN;
assert_eq!(n.checked_ilog2().map_or(0, |n| n + 1), 0);
```

符号付き整数で符号ビットも含めて値を表すのに必要なビット数は、最初の方法を以下のように修正することで求めることができます。

```diff rust
let answer: i8 = 42;
-assert_eq!(answer.ilog2() + 1, 6);
+assert_eq!(answer.ilog2() + 2, 7);
```

## 負の整数の場合

Pythonの`int.bit_length()`のように符号を除いた負の整数$n$を表すのに必要なビット数を求めたいとき（$-37$のときは$37$）、$n \neq 0$であるときは`n.unsigned_abs().ilog2() + 1`で求めることができます。

```rust
let n: i32 = -37;
assert_eq!(n.unsigned_abs().ilog2() + 1, 6);
```

殆どの場合は[`abs()`](https://doc.rust-lang.org/std/primitive.i32.html#method.abs)で問題ないですが、$n$が[`i32::MIN`](https://doc.rust-lang.org/std/primitive.i32.html#associatedconstant.MIN)などのその型の最小値のときにオーバーフローが発生するので、[`unsigned_abs()`](https://doc.rust-lang.org/std/primitive.i32.html#method.unsigned_abs)を使う方が安全です。

符号ビットも含めた負の整数$n$を表すのに必要なビット数を求めたいとき、$n < -1$であるときは`(n + 1).abs().ilog2() + 2`で求めることができます。

```rust
let n: i16 = -128;
assert_eq!((n + 1).abs().ilog2() + 2, 8);

let m: i16 = -129;
assert_eq!((m + 1).abs().ilog2() + 2, 9);
```

$n \geqq -1$な可能性があるときは、`checked_ilog2()`を利用することで自然数の場合と同様にパニックを避けることができます。

$n = 0$と$n = -1$も含めた全ての符号付き整数で値を表すのに必要なビット数は、以下の方法で求めることができます。

```rust
let n: i32 = -1;
let bit_width = match n {
    0 | -1 => 0,
    n if n.is_positive() => n.ilog2() + 2,
    n => (n + 1).abs().ilog2() + 2,
};
assert_eq!(bit_width, 0);
```

## 終わりに

紹介した方法だと$n = 0$または$n = -1$のときは必要なビット数を求めることができないので、これらの場合にも対応したもっと良い方法があるかもしれません。
