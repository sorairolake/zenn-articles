---
title: "Rustでビット精度の整数型を使えるようにするライブラリを作った"
emoji: "🦀"
type: "tech"
topics: ["api", "rust"]
published: true
published_at: 2024-11-13 15:00
---

## はじめに

[Rust](https://www.rust-lang.org/)のプリミティブ整数型のビット幅は他の多くの言語と同様に8の倍数です。
殆どの場合はこれで十分だと思いますが、7ビットなどの8の倍数でないビット幅の整数型が欲しい場合がまれにあると思います。
今回紹介する`bit-int`クレートは、そのような場合に利用できる任意のビット精度であることを保証した整数型を使えるようにするライブラリです。

https://github.com/sorairolake/bit-int

## 作った理由

最近、[C23](https://en.cppreference.com/w/c/23)に興味を持って調べていたときに、ビット精度の整数型の`_BitInt(n)`が追加されたことを知り、Rustでもビット精度の整数型を実装してみたいと思ったので作りました。

## データ型

符号付き整数型は[`BitInt`](https://docs.rs/bit-int/0.1.0/bit_int/struct.BitInt.html)として実装しており、符号無し整数型は[`BitUint`](https://docs.rs/bit-int/0.1.0/bit_int/struct.BitUint.html)として実装しています。

`BitInt`は以下のように定義されています:

```rust
pub struct BitInt<T: Signed + PrimInt, const N: u32>(T);
```

`T`には[`num-traits`](https://crates.io/crates/num-traits)クレートの[`Signed`](https://docs.rs/num-traits/0.2.19/num_traits/sign/trait.Signed.html)トレイトと[`PrimInt`](https://docs.rs/num-traits/0.2.19/num_traits/int/trait.PrimInt.html)トレイトを実装している型（全てのプリミティブ符号付き整数型）を指定できます。
`N`は符号ビットも含めた値のビット数です。

`BitUint`は以下のように定義されています:

```rust
pub struct BitUint<T: Unsigned + PrimInt, const N: u32>(T);
```

`T`には`num-traits`クレートの[`Unsigned`](https://docs.rs/num-traits/0.2.19/num_traits/sign/trait.Unsigned.html)トレイトと`PrimInt`トレイトを実装している型（全てのプリミティブ符号無し整数型）を指定できます。
`N`は値のビット数です。

`N`の範囲は`1`から`T::BITS`で、範囲外のビット数を指定した場合にはコンパイルエラーになります。

## 使い方

初期化には`new`メソッドか`new_unchecked`メソッドを使います。
前者は与えられた値が`N`ビットに収まるかを検査し、収まる場合は`Some`を返し、そうでない場合は`None`を返します。
後者は検査をしないで初期化をする`unsafe`メソッドで、与えられた値が`N`ビットに収まらないときの動作は未定義です。

値をプリミティブ型として取得するには`get`メソッドを使います。

```rust
let n = BitInt::<i32, 7>::new(42);
assert_eq!(n.map(BitInt::get), Some(42));

let m = BitInt::<i32, 6>::new(42);
assert!(m.is_none());
```

プリミティブ整数型と同様に、最小値、最大値、ビット数を表す定数を定義しています。

```rust
assert_eq!(BitInt::<i32, 7>::MIN.get(), -64);
assert_eq!(BitInt::<i32, 7>::MAX.get(), 63);
assert_eq!(BitInt::<i32, 7>::BITS, 7);
```

演算は現時点では四則演算だけ実装しています。
今後、プリミティブ型にある他の演算も実装するつもりです。

```rust
let n = BitInt::<i32, 7>::new(42).unwrap();

assert_eq!(n.checked_add(21).map(BitInt::get), Some(63));
assert!(n.checked_add(22).is_none());
```

## 終わりに

Rustでビット精度の整数型を使えるようにするライブラリの`bit-int`クレートを紹介しました。
開発を始めたばかりで機能が少ないので、今後機能を強化できたら良いと思います。

https://crates.io/crates/bit-int

https://docs.rs/bit-int
