---
title: "Zig版JSONみたいな「ZON」について"
emoji: "⚡"
type: "tech"
topics: ["json", "zig"]
published: true
---

**ZON**（Zig Object Notation）は、[Zig](https://ziglang.org/)で使われているテキストファイルフォーマットです。
ZONはZigのビルドシステムの[`build.zig.zon`](https://github.com/ziglang/zig/blob/0.14.0/doc/build.zig.zon.md)で使われています。
[JSON](https://datatracker.ietf.org/doc/html/rfc8259)の構文がJavaScriptのオブジェクトの表記法に由来しているように、ZONの構文はZigの文法に由来しています。
ZONの構文は基本的にZigの文法のサブセットですが、Zigとは異なりNaNと無限大を表すリテラル（`nan`、`inf`）があるという違いがあります。

## 例

```zig
.{
    .a = 1.5,
    .b = "hello, world!",
    .c = .{ true, false },
    .d = .{ 1, 2, 3 },
}
```

## JSONとの違い

JSONとは異なり、ZONはコメントを書くことができます。

```zig
// コメント
10
```

また、末尾にコンマを付けることができます。

```zig:with_comma.zon
.{
    .a = 1.5,
    .b = "hello, world!",
    .c = .{
        true,
        false,
    },
    .d = .{
        1,
        2,
        3,
    },
}
```

```zig:without_comma.zon
.{ .a = 1.5, .b = "hello, world!", .c = .{ true, false }, .d = .{ 1, 2, 3 } }
```

以下のようにZONファイルに対して`zig fmt`を実行することでフォーマットできます。

```sh
$ zig fmt foo.zon
foo.zon
```

整数リテラルは10進数以外に2進数、8進数、16進数でも表記できます。

```zig
.{
    .hex = 0xff,
    .octal = -0o77,
    .binary = 0b11,
}
```

## シリアライズとデシリアライズ

Zig 0.14.0で追加された[`std.zon`](https://ziglang.org/documentation/0.14.0/std/#std.zon)を使うことでZONのシリアライズとデシリアライズができます。
[`std.zon.parse`](https://ziglang.org/documentation/0.14.0/std/#std.zon.parse)の提供する機能でデシリアライズができ、[`std.zon.stringify`](https://ziglang.org/documentation/0.14.0/std/#std.zon.stringify)の提供する機能でシリアライズができます。

また、以下のように[`@import`](https://ziglang.org/documentation/0.14.0/#import)を使うとコンパイル時にZONをデシリアライズできます。

```zig
const foo: Foo = @import("foo.zon");
```

## 参考文献

- <https://ziglang.org/documentation/0.14.0/std/#std.zon>
- <https://ziglang.org/download/0.14.0/release-notes.html>
