---
title: "Rustの整数オーバーフローまとめ"
emoji: "🦀"
type: "tech"
topics: ["rust"]
published: true
published_at: 2024-03-07 12:00
---

## プロファイル設定

Rustの実行時整数オーバーフローの動作は[`overflow-checks`](https://doc.rust-lang.org/cargo/reference/profiles.html#overflow-checks)の値によって決まります。
`true`の場合はオーバーフローが発生したらパニックして、`false`の場合は溢れた桁を無視した値を返します。
この設定は`dev`プロファイルでは`true`で、`release`プロファイルでは`false`です。

## 制御方法

計算時にオーバーフローが発生した場合のためのメソッドと型が用意されています。

### Checked

`checked_*`はオーバーフローが発生した場合に`None`を返します。

```rust
assert_eq!((u8::MAX - 1).checked_add(1), Some(u8::MAX));
assert!(u8::MAX.checked_add(1).is_none());
```

### Overflowing

`overflowing_*`は溢れた桁を無視した計算結果とオーバーフローが発生したかの真理値を返します。

```rust
assert_eq!((u8::MAX - 1).overflowing_add(1), (u8::MAX, false));
assert_eq!(u8::MAX.overflowing_add(1), (u8::MIN, true));
```

### Saturating

`saturating_*`はオーバーフローが発生した場合に飽和させた値を返します。

```rust
assert_eq!(u8::MIN.saturating_add(1), 1);
assert_eq!(u8::MAX.saturating_add(1), u8::MAX);
```

[`Saturating`](https://doc.rust-lang.org/std/num/struct.Saturating.html)で値を包むと通常の演算子でも同様の結果になります。

```rust
assert_eq!((Saturating(u8::MIN) + Saturating(1)).0, 1);
assert_eq!((Saturating(u8::MAX) + Saturating(1)).0, u8::MAX);
```

### Wrapping

`wrapping_*`は溢れた桁を無視した計算結果を返します。

```rust
assert_eq!((u8::MAX - 1).wrapping_add(1), u8::MAX);
assert_eq!(u8::MAX.wrapping_add(1), u8::MIN);
```

[`Wrapping`](https://doc.rust-lang.org/std/num/struct.Wrapping.html)で値を包むと通常の演算子でも同様の結果になります。

```rust
assert_eq!((Wrapping(u8::MAX - 1) + Wrapping(1)).0, u8::MAX);
assert_eq!((Wrapping(u8::MAX) + Wrapping(1)).0, u8::MIN);
```

## 参考文献

- <https://doc.rust-lang.org/cargo/reference/profiles.html>
- <https://doc.rust-lang.org/std/primitive.u8.html>
