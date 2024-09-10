---
title: "元号のデータセットを作ったはなし"
emoji: "🗾"
type: "tech"
topics: ["dataset", "元号"]
published: true
published_at: 2024-06-05 07:00
---

## はじめに

[日本の元号](<https://ja.wikipedia.org/wiki/%E5%85%83%E5%8F%B7%E4%B8%80%E8%A6%A7_(%E6%97%A5%E6%9C%AC)>)のデータセットを作りました。
北朝を含めた大化から令和までの248個の全ての元号に対応しています。

## 構造

データは次のようなYAMLの連想配列で表現されています。

```yaml:modern.yaml
era:
  heisei:
    number: 231
    kanji: 平成
    kyujitai: null
    english: Heisei
    start: 1989-01-08
    end: 2019-05-01
```

キーと値のペアの意味は次の通りです。

- `number`: 何番目の元号かを表しています。
  232個の元号一覧に含まれないときは`null`です。
- `kanji`: 新字体での元号名を表しています。
- `kyujitai`: 旧字体（異体字セレクタを含む）での元号名を表しています。
  新字体と字体が同じときは`null`です。
- `english`: 英語での元号名を表しています。
  マクロンが付いている場合があります。
- `start`: その元号が始まった日付を表しています。
- `end`: その元号が終わった日付を表しています。
  現在の元号のときは`null`です。

南北朝時代では次のキーと値のペアが存在します。

- `southern-number`: 南朝の何番目の元号かを表しています。
- `northern-number`: 北朝の何番目の元号かを表しています。

YAMLを使用した理由は次の通りです。

1.  タイムスタンプ型が存在する。
2.  `null`が存在する。
3.  JSONへの変換が構造を殆ど維持したままできる。

## JSONへの変換

YAMLファイルをJSONファイルに変換するための[Deno](https://deno.com/)スクリプトを含んでいます。
実行時に依存関係を自動的にダウンロードするので、簡単に実行することができます。

```sh
# `deno run`で実行
deno run --allow-read --allow-write scripts/yaml2json.ts

# 直接実行
./scripts/yaml2json.ts
```

出力例:

```json:modern.json
{
  "era": {
    "heisei": {
      "number": 231,
      "kanji": "平成",
      "kyujitai": null,
      "english": "Heisei",
      "start": "1989-01-08T00:00:00.000Z",
      "end": "2019-05-01T00:00:00.000Z"
    }
  }
}
```

## 実行例

232番目の元号の新字体での元号名を取得する。

```sh
$ cat assets/json/*.json | jq '.[][] | select(.number == 232) | .kanji'
"令和"
```

18世紀の元号の個数を数える。

```sh
$ cat assets/yaml/edo.yaml | yq '.[][] | select(.start >= "1701-01-01" and .end < "1801-01-01") | .number' | wc -l
11
```
