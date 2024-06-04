---
title: "プリミティブ型に128ビット整数型があるプログラミング言語"
emoji: "🔢"
type: "tech"
topics: ["julia", "rust", "solidity", "zig"]
published: true
published_at: 2024-03-06 11:00
---

大抵のプログラミング言語のプリミティブ型に64ビット整数型はありますが、128ビット整数型がある言語は少ないように思ったので調べてみました。

## 一覧

他にも対応している言語があるかもしれません。

| 言語                                  | 符号付き | 符号なし  | 脚注     |
| ------------------------------------- | -------- | --------- | -------- |
| [Julia](https://julialang.org/)       | `Int128` | `UInt128` | [^1][^2] |
| [Rust](https://www.rust-lang.org/)    | `i128`   | `u128`    | [^3][^4] |
| [Solidity](https://soliditylang.org/) | `int128` | `uint128` | [^5]     |
| [Zig](https://ziglang.org/)           | `i128`   | `u128`    | [^6]     |

## Julia

現時点ではJuliaのプリミティブ型にこれより大きいビット数の整数型はありません。
Juliaは[`Base`](https://docs.julialang.org/en/v1/base/base/)パッケージ（標準ライブラリ）で任意精度演算をサポートしており、128ビット整数型の範囲外の整数を扱いたい場合は[`BigInt`](https://docs.julialang.org/en/v1/base/numbers/#Base.GMP.BigInt)が利用できます。

## Rust

現時点ではRustのプリミティブ型にこれより大きいビット数の整数型はありません。
また、標準ライブラリに多倍長整数型はないので、128ビット整数型の範囲外の整数を扱いたい場合は[`num-bigint`](https://crates.io/crates/num-bigint)のような外部クレートを利用します。

## Solidity

Solidityでは`int8`と`uint8`から`int256`と`uint256`までの8の倍数の整数型が定義されています。

## Zig

Zigでは`65535`ビットまでの任意のビット幅の整数型を宣言できます。
例えば、`i7`は7ビット符号付き整数型で、`u256`は256ビット符号なし整数型です。
任意精度演算が必要な場合は標準ライブラリの[`std.math.big.int`](https://ziglang.org/documentation/0.11.0/std/#A;std:math.big.int)にある型が利用できます。

[^1]: <https://docs.julialang.org/en/v1/base/numbers/#Core.Int128>

[^2]: <https://docs.julialang.org/en/v1/base/numbers/#Core.UInt128>

[^3]: <https://doc.rust-lang.org/std/primitive.i128.html>

[^4]: <https://doc.rust-lang.org/std/primitive.u128.html>

[^5]: <https://docs.soliditylang.org/en/v0.8.24/types.html#integers>

[^6]: <https://ziglang.org/documentation/0.11.0/#Primitive-Types>
