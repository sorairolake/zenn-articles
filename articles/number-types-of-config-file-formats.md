---
title: "JSON・TOML・YAMLの数値型の違い"
emoji: "🔢"
type: "tech"
topics: ["json", "toml", "yaml", "比較"]
published: true
published_at: 2024-06-04 19:00
---

## はじめに

JSON・TOML・YAMLの仕様を見ていたら数値型に結構違いがあるように思ったのでまとめてみました。

この記事ではそれぞれのファイルフォーマットの最新の仕様を対象とします。

- [RFC 8259 - The JavaScript Object Notation (JSON) Data Interchange Format](https://datatracker.ietf.org/doc/html/rfc8259)
- [TOML v1.0.0](https://toml.io/ja/v1.0.0)
- [YAML Ain’t Markup Language (YAML™) version 1.2](https://yaml.org/spec/1.2.2/)

## JSON

JSONの`Number`型（数値型）はJavaScriptの数値型と同じくすべての数値が浮動小数点数として扱われます。
JavaScriptでは数値型の精度はIEEE 754の倍精度浮動小数点数（binary64）と定められていますが、JSONの数値型の精度は処理系依存です[^1]。

JavaScript（ES2021）の数値型との主な違いは次の通りです。

1. 10進数表記だけ対応。
2. 数値の前に`+`を付けられない。
3. `NaN`と`Infinity`と`-Infinity`には対応していない。
4. `_`で数値を区切ることはできない。

```json:number.json
{
  "integer": 42,
  "float": 3.14,
  "exponent": 5E+22
}
```

## TOML

### 整数型

TOMLの整数型は64ビット符号付き整数型です。

主な仕様は次の通りです。

1. 数値を`_`で区切ることができる。
2. 正の数のときは{2,8,16}進数表記が使える。

```toml:integer.toml
positive = 42
zero = 0
negative = -17

hex = 0xdead_beef
oct = 0o755
bin = 0b11010110
```

### 浮動小数点型

TOMLの浮動小数点型はIEEE 754の倍精度浮動小数点数（binary64）です。

```toml:float.toml
positive = 3.14
negative = -0.01

exponent = 5e+22

infinity = inf

not-a-number = nan
```

## YAML

### 整数型

YAMLの整数型は多倍長整数です。

```yaml:integer.yaml
positive: 34
zero: 0
negative: -12

hex: 0xDEADBEEF
oct: 0o755
```

#### YAML 1.1との違い

YAML 1.1からYAML 1.2では数値の表記関連でいくつか破壊的変更が行われています。

1. 数値を`_`で区切ることができなくなった。
2. 8進数表記の接頭辞が`0`から`0o`に変更された。`010`は8ではなく10と解釈されるようになった。
3. 2進数表記と60進数表記が削除された。

### 浮動小数点型

YAMLの浮動小数点型の精度は処理系依存です。

```yaml:float.yaml
positive: 3.14
negative: -0.01

exponent: 2.3e4

infinity: .inf

not-a-number: .nan
```

## まとめ

### 整数

|                          |    JSON    |   TOML   |    YAML    |
| :----------------------: | :--------: | :------: | :--------: |
|          サイズ          | 処理系依存 | 64ビット | 処理系依存 |
|           符号           |     ✅     |    ✅    |     ✅     |
|     先頭のプラス記号     |     ❌     |    ✅    |     ✅     |
|         先行ゼロ         |     ❌     |    ❌    |     ✅     |
| アンダースコアで桁区切り |     ❌     |    ✅    |     ❌     |
|        2進数表記         |     ❌     |    ✅    |     ❌     |
|        8進数表記         |     ❌     |    ✅    |     ✅     |
|        16進数表記        |     ❌     |    ✅    |     ✅     |

### 浮動小数点数

|                          |    JSON    |   TOML   |    YAML    |
| :----------------------: | :--------: | :------: | :--------: |
|           精度           | 処理系依存 | binary64 | 処理系依存 |
|     先頭のプラス記号     |     ❌     |    ✅    |     ✅     |
|         先行ゼロ         |     ❌     |    ❌    |     ✅     |
| アンダースコアで桁区切り |     ❌     |    ✅    |     ❌     |
|         指数表記         |     ✅     |    ✅    |     ✅     |
|          無限大          |     ❌     |    ✅    |     ✅     |
|           NaN            |     ❌     |    ✅    |     ✅     |

## 参考文献

- <https://datatracker.ietf.org/doc/html/rfc8259#section-6>
- <https://toml.io/ja/v1.0.0#%E6%95%B4%E6%95%B0>
- <https://toml.io/ja/v1.0.0#%E6%B5%AE%E5%8B%95%E5%B0%8F%E6%95%B0%E7%82%B9%E6%95%B0>
- <https://yaml.org/spec/1.2.2/#10213-integer>
- <https://yaml.org/spec/1.2.2/#10214-floating-point>
- <https://yaml.org/spec/1.2.2/#1032-tag-resolution>
- <https://yaml.org/spec/1.2.2/ext/changes/>

[^1]: 仕様ではbinary64として扱うことで良好な相互運用性を実現できると述べられています。
