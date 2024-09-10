---
title: "Unix時間とWindowsのFILETIMEを変換する"
emoji: "🕐"
type: "tech"
topics: ["datetime", "unix", "windows"]
published: true
published_at: 2024-05-26 17:00
---

## はじめに

Unix系では1970-01-01 00:00:00 UTC（Unixエポック）からの経過秒数で表される[Unix時間](https://ja.wikipedia.org/wiki/UNIX%E6%99%82%E9%96%93)が主に使われていますが、Windowsでは1601-01-01 00:00:00 UTC（NTタイムエポック）からの100ナノ秒単位の経過秒数で表される[`FILETIME`](https://learn.microsoft.com/ja-jp/windows/win32/api/minwinbase/ns-minwinbase-filetime)が使われています。

今回はこの2つのタイムスタンプの変換方法についてまとめたいと思います。

## 前提条件

- [`time_t`](https://en.cppreference.com/w/c/chrono/time_t)などで表される秒単位のUnix時間のデータ型は64ビット符号付き整数型とします。
- [`timespec`](https://en.cppreference.com/w/c/chrono/timespec)などで表されるナノ秒単位のUnix時間のデータ型は128ビット符号付き整数型とします。
- `FILETIME`のデータ型は64ビット符号なし整数型とします。
- 整数同士の割り算の結果は小数点以下を切り捨てた整数値とします。

## Unix時間 to FILETIME

Unix時間から`FILETIME`への変換では、Unix時間がNTタイムエポックから`FILETIME`の最大値の+60056-05-28 05:36:10.955161500 UTCに収まらない可能性があるので、範囲内かを確認する処理が必要になります。

### 秒単位

秒単位のUnix時間を`FILETIME`に変換するには以下のような処理を行います。

1.  Unix時間が1,833,029,933,770（`FILETIME`の最大値）以下であることを確認する。
2.  Unix時間にUnixエポックとNTタイムエポックの差の秒数の11,644,473,600を足す。
3.  2の結果が正の数であることを確認する。
4.  2の結果に10,000,000を掛けて100ナノ秒単位にする。

https://github.com/sorairolake/nt-time/blob/v0.7.0/src/file_time/unix_time.rs#L94-L104

### ナノ秒単位

ナノ秒単位のUnix時間を`FILETIME`に変換するには以下のような処理を行います。

1.  Unix時間が1,833,029,933,770,955,161,500（`FILETIME`の最大値）以下であることを確認する。
2.  Unix時間にUnixエポックとNTタイムエポックの差のナノ秒数の11,644,473,600,000,000,000を足す。
3.  2の結果が正の数であることを確認する。
4.  2の結果を100で割って100ナノ秒単位にする。

https://github.com/sorairolake/nt-time/blob/v0.7.0/src/file_time/unix_time.rs#L137-L148

## FILETIME to Unix時間

64ビット符号付き整数型のUnix時間ではおよそ紀元前3000億年からおよそ3000億年の範囲を表すことができるので、`FILETIME`からUnix時間への変換は常に成功します。
ナノ秒単位のUnix時間の場合もこの変換は128ビット符号付き整数型に収まるので同様です。

### 秒単位

`FILETIME`を秒単位のUnix時間に変換するには以下のような処理を行います。

1.  `FILETIME`を10,000,000で割って秒単位にする。
2.  1の結果からUnixエポックとNTタイムエポックの差の秒数の11,644,473,600を引く。

https://github.com/sorairolake/nt-time/blob/v0.7.0/src/file_time/unix_time.rs#L30-L34

### ナノ秒単位

`FILETIME`をナノ秒単位のUnix時間に変換するには以下のような処理を行います。

1.  `FILETIME`に100を掛けてナノ秒単位にする。
2.  1の結果からUnixエポックとNTタイムエポックの差のナノ秒数の11,644,473,600,000,000,000を引く。

https://github.com/sorairolake/nt-time/blob/v0.7.0/src/file_time/unix_time.rs#L57-L59

## まとめ

Unix時間と`FILETIME`の変換方法についてまとめました。
今回は64ビット符号付き整数型の秒単位のUnix時間と128ビット符号付き整数型のナノ秒単位のUnix時間を扱いましたが、[2038年問題](https://ja.wikipedia.org/wiki/2038%E5%B9%B4%E5%95%8F%E9%A1%8C)で知られている古い32ビット符号付き整数型の秒単位のUnix時間の場合は`FILETIME`からUnix時間への変換が失敗する可能性がある[^1]など、データ型のサイズによって変換が常に成功するか失敗する可能性があるかが変化することに注意してください。

[^1]: `FILETIME`が1901-12-13 20:45:52 UTCから2038-01-19 03:14:07 UTCに収まらない日時を表している場合に失敗します。
