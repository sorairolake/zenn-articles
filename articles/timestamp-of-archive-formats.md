---
title: "アーカイブファイルフォーマットのタイムスタンプまとめ"
emoji: "⏱️"
type: "tech"
topics: ["7z", "tar", "timestamp", "zip"]
published: true
---

## はじめに

この記事は、Rustの[`zip`](https://crates.io/crates/zip)クレートで「NTFS Extra Field」を読み取れるようにするパッチを書いたときに、他のアーカイブファイルフォーマットのタイムスタンプの精度やどの情報が格納できるかなどが気になったので調べた結果をまとめたものです。

## tar

| フォーマット | 精度 | atime | mtime | ctime |
| :----------: | :--: | :---: | :---: | :---: |
|      v7      | 1秒  |  ❌   |  ✅   |  ❌   |
|    ustar     | 1秒  |  ❌   |  ✅   |  ❌   |
|     gnu      | 1秒  |  ✅   |  ✅   |  ✅   |
|     pax      | 任意 |  ✅   |  ✅   |  ✅   |

どのフォーマットでもタイムスタンプはUnix時間で表現されますが、v7とustarの場合は「1970-01-01 00:00:00 UTC」から「2242-03-16 12:56:31 UTC」に範囲が制限され、gnuではより広い範囲のタイムスタンプを格納できます。

paxは拡張ヘッダに文字列として格納され、精度は通常1ナノ秒です。
paxは対応していない環境ではustarとして扱われます。

## 7z

|   精度    | atime | mtime | ctime |
| :-------: | :---: | :---: | :---: |
| 100ナノ秒 |  ✅   |  ✅   |  ✅   |

7zはタイムスタンプにWindowsの[ファイル時刻](https://learn.microsoft.com/ja-jp/windows/win32/sysinfo/file-times)を使用します。
これは「1601-01-01 00:00:00 UTC」から経過した100ナノ秒間隔の数を表す64ビット値です。
従って、「+60056-05-28 05:36:10.955161500 UTC」まで表すことができますが、多くの環境では符号付き64ビット整数型の最大値の「+30828-09-14 02:48:05.477580700 UTC」に制限されています。

## ZIP

| 精度 | atime | mtime | ctime |
| :--: | :---: | :---: | :---: |
| 2秒  |  ❌   |  ✅   |  ❌   |

ZIPはタイムスタンプに[MS-DOSの日付と時刻](https://learn.microsoft.com/ja-jp/windows/win32/sysinfo/ms-dos-date-and-time)を使用します。
範囲は「1980-01-01 00:00:00」から「2107-12-31 23:59:58」で、精度は2秒です。

ただし、ZIPの拡張フィールドによって組み込み以外のタイムスタンプを格納することもできます。
以下ではいくつかの拡張フィールドを取り上げます。

|           拡張フィールド           |   精度    | atime | mtime | ctime |
| :--------------------------------: | :-------: | :---: | :---: | :---: |
|          NTFS Extra Field          | 100ナノ秒 |  ✅   |  ✅   |  ✅   |
|          UNIX Extra Field          |    1秒    |  ✅   |  ✅   |  ❌   |
|   Extended Timestamp Extra Field   |    1秒    |  ✅   |  ✅   |  ✅   |
| Info-ZIP Unix Extra Field (type 1) |    1秒    |  ✅   |  ✅   |  ❌   |

NTFS Extra Fieldは7zのタイムスタンプと同様にWindowsのファイル時刻を格納します。
UNIX Extra Field、Extended Timestamp Extra Field、Info-ZIP Unix Extra Field (type 1)は符号付き32ビットのUnix時間を格納します。
拡張フィールドを扱えるかはZIP処理系に依存します。

## 参考文献

- <https://www.gnu.org/software/tar/manual/html_node/Standard.html>
- <https://www.gnu.org/software/tar/manual/html_chapter/Formats.html>
- <https://www.gnu.org/software/tar/manual/html_node/Large-or-Negative-Values.html>
- <https://py7zr.readthedocs.io/en/stable/archive_format.html>
- <https://pkware.cachefly.net/webdocs/casestudies/APPNOTE.TXT>
- <https://libzip.org/specifications/extrafld.txt>
