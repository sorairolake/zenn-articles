---
title: "C言語、C++、Rustで関数を使ってビット操作をする"
emoji: "🔀"
type: "tech"
topics: ["c", "cpp", "rust"]
published: true
---

## はじめに

C23以降のC言語、C++20以降のC++、Rustは関数（メソッド）を使ってビット操作をすることができます。
これらの関数はC言語では[`<stdbit.h>`](https://en.cppreference.com/w/c/header/stdbit.html)、C++では[`<bit>`](https://en.cppreference.com/w/cpp/header/bit.html)、Rustではプリミティブ整数型のメソッドとして定義されています。
この記事では、これらの関数を操作ごとに紹介します。

## 整数値が2の累乗かを判定する

C言語では`stdc_has_single_bit`関数を使って求めることができます。

```c
#include <assert.h>
#include <stdbit.h>

assert(stdc_has_single_bit(0b10000u));
```

C++では`std::has_single_bit`関数を使って求めることができます。

```cpp
#include <bit>
#include <cassert>

assert(std::has_single_bit(0b10000u));
```

Rustでは[`is_power_of_two`](https://doc.rust-lang.org/core/primitive.u32.html#method.is_power_of_two)メソッドを使って求めることができます。

```rust
assert!(0b10000_u32.is_power_of_two());
```

## 整数値を2の累乗値に切り上げる

C言語では`stdc_bit_ceil`関数を使って求めることができます。

```c
#include <assert.h>
#include <stdbit.h>

assert(stdc_bit_ceil(3u) == 4);
```

C++では`std::bit_ceil`関数を使って求めることができます。

```cpp
#include <bit>
#include <cassert>

assert(std::bit_ceil(3u) == 4);
```

Rustでは[`next_power_of_two`](https://doc.rust-lang.org/core/primitive.u32.html#method.next_power_of_two)メソッドを使って求めることができます。

```rust
assert_eq!(3_u32.next_power_of_two(), 4);
```

## 整数値を2の累乗値に切り下げる

C言語では`stdc_bit_floor`関数を使って求めることができます。

```c
#include <assert.h>
#include <stdbit.h>

assert(stdc_bit_floor(0b0110'0100u) == 0b0100'0000);
```

C++では`std::bit_floor`関数を使って求めることができます。

```cpp
#include <bit>
#include <cassert>

assert(std::bit_floor(0b0110'0100u) == 0b0100'0000);
```

Rustでは[`isolate_most_significant_one`](https://doc.rust-lang.org/nightly/core/primitive.u32.html#method.isolate_most_significant_one)メソッドを使って求めることができます。
現時点ではこのメソッドはnightlyチャンネルでのみ利用できます。

```rust
#![feature(isolate_most_least_significant_one)]

assert_eq!(0b0110_0100_u32.isolate_most_significant_one(), 0b0100_0000);
```

## 整数値を表現するのに必要な最小ビット数を求める

C言語では`stdc_bit_width`関数を使って求めることができます。

```c
#include <assert.h>
#include <stdbit.h>

assert(stdc_bit_width(0b1110u) == 4);
```

C++では`std::bit_width`関数を使って求めることができます。

```cpp
#include <bit>
#include <cassert>

assert(std::bit_width(0b1110u) == 4);
```

Rustでは[`bit_width`](https://doc.rust-lang.org/nightly/core/primitive.u32.html#method.bit_width)メソッドを使って求めることができます。
現時点ではこのメソッドはnightlyチャンネルでのみ利用できます。

```rust
#![feature(uint_bit_width)]

assert_eq!(0b1110_u32.bit_width(), 4);
```

## 最上位ビットから連続する0のビットを数える

C言語では`stdc_leading_zeros`関数を使って求めることができます。

```c
#include <assert.h>
#include <stdbit.h>
#include <stdint.h>

assert(stdc_leading_zeros(UINT32_MAX >> 2) == 2);
```

C++では`std::countl_zero`関数を使って求めることができます。

```cpp
#include <bit>
#include <cassert>
#include <cstdint>

assert(std::countl_zero(UINT32_MAX >> 2) == 2);
```

Rustでは[`leading_zeros`](https://doc.rust-lang.org/core/primitive.u32.html#method.leading_zeros)メソッドを使って求めることができます。

```rust
assert_eq!((u32::MAX >> 2).leading_zeros(), 2);
```

## 最下位ビットから連続する0のビットを数える

C言語では`stdc_trailing_zeros`関数を使って求めることができます。

```c
#include <assert.h>
#include <stdbit.h>

assert(stdc_trailing_zeros(0b010'1000u) == 3);
```

C++では`std::countr_zero`関数を使って求めることができます。

```cpp
#include <bit>
#include <cassert>

assert(std::countr_zero(0b010'1000u) == 3);
```

Rustでは[`trailing_zeros`](https://doc.rust-lang.org/core/primitive.u32.html#method.trailing_zeros)メソッドを使って求めることができます。

```rust
assert_eq!(0b010_1000_u32.trailing_zeros(), 3);
```

## 最上位ビットから連続する1のビットを数える

C言語では`stdc_leading_ones`関数を使って求めることができます。

```c
#include <assert.h>
#include <stdbit.h>
#include <stdint.h>

assert(stdc_leading_ones(~(UINT32_MAX>>2)) == 2);
```

C++では`std::countl_one`関数を使って求めることができます。

```cpp
#include <bit>
#include <cassert>
#include <cstdint>

assert(std::countl_one(~(UINT32_MAX >> 2)) == 2);
```

Rustでは[`leading_ones`](https://doc.rust-lang.org/core/primitive.u32.html#method.leading_ones)メソッドを使って求めることができます。

```rust
assert_eq!((!(u32::MAX >> 2)).leading_ones(), 2);
```

## 最下位ビットから連続する1のビットを数える

C言語では`stdc_trailing_ones`関数を使って求めることができます。

```c
#include <assert.h>
#include <stdbit.h>

assert(stdc_trailing_ones(0b101'0111u) == 3);
```

C++では`std::countr_one`関数を使って求めることができます。

```cpp
#include <bit>
#include <cassert>

assert(std::countr_one(0b101'0111u) == 3);
```

Rustでは[`trailing_ones`](https://doc.rust-lang.org/core/primitive.u32.html#method.trailing_ones)メソッドを使って求めることができます。

```rust
assert_eq!(0b101_0111_u32.trailing_ones(), 3);
```

## 1に設定されたビットを数える

C言語では`stdc_count_ones`関数を使って求めることができます。

```c
#include <assert.h>
#include <stdbit.h>

assert(stdc_count_ones(0b0100'1100u) == 3);
```

C++では`std::popcount`関数を使って求めることができます。

```cpp
#include <bit>
#include <cassert>

assert(std::popcount(0b0100'1100u) == 3);
```

Rustでは[`count_ones`](https://doc.rust-lang.org/core/primitive.u32.html#method.count_ones)メソッドを使って求めることができます。

```rust
assert_eq!(0b0100_1100_u32.count_ones(), 3);
```

## まとめ

|                                                | C言語                 | C++                   | Rust                           |
| ---------------------------------------------- | --------------------- | --------------------- | ------------------------------ |
| 整数値が2の累乗かを判定する                    | `stdc_has_single_bit` | `std::has_single_bit` | `is_power_of_two`              |
| 整数値を2の累乗値に切り上げる                  | `stdc_bit_ceil`       | `std::bit_ceil`       | `next_power_of_two`            |
| 整数値を2の累乗値に切り下げる                  | `stdc_bit_floor`      | `std::bit_floor`      | `isolate_most_significant_one` |
| 整数値を表現するのに必要な最小ビット数を求める | `stdc_bit_width`      | `std::bit_width`      | `bit_width`                    |
| 最上位ビットから連続する0のビットを数える      | `stdc_leading_zeros`  | `std::countl_zero`    | `leading_zeros`                |
| 最下位ビットから連続する0のビットを数える      | `stdc_trailing_zeros` | `std::countr_zero`    | `trailing_zeros`               |
| 最上位ビットから連続する1のビットを数える      | `stdc_leading_ones`   | `std::countl_one`     | `leading_ones`                 |
| 最下位ビットから連続する1のビットを数える      | `stdc_trailing_ones`  | `std::countr_one`     | `trailing_ones`                |
| 1に設定されたビットを数える                    | `stdc_count_ones`     | `std::popcount`       | `count_ones`                   |
