---
title: "YAMLはJSONの構文でも書けます"
emoji: "📝"
type: "tech"
topics: ["json", "yaml"]
published: true
published_at: 2025-05-26 07:00
---

## はじめに

[YAML](https://yaml.org/)は偶然にも[JSON](https://www.json.org/)のほぼスーパーセット（上位互換）になっており、YAML 1.2からは厳密なスーパーセットであることが仕様で定義されています。

https://yaml.org/spec/1.2.2/#12-yaml-history

従って、YAMLを書くときにはJSONの構文がそのまま使えます。

## 例

例として<https://toml.io/>に載っている以下のTOMLドキュメントを利用します。

```toml:input.toml
# This is a TOML document

title = "TOML Example"

[owner]
name = "Tom Preston-Werner"
dob = 1979-05-27T07:32:00-08:00

[database]
enabled = true
ports = [ 8000, 8001, 8002 ]
data = [ ["delta", "phi"], [3.14] ]
temp_targets = { cpu = 79.5, case = 72.0 }

[servers]

[servers.alpha]
ip = "10.0.0.1"
role = "frontend"

[servers.beta]
ip = "10.0.0.2"
role = "backend"
```

これを<https://github.com/mikefarah/yq>を使ってJSONに変換します。

```sh
yq -o json input.toml > output.json
```

```json:output.json
{
  "title": "TOML Example",
  "owner": {
    "name": "Tom Preston-Werner",
    "dob": "1979-05-27T07:32:00-08:00"
  },
  "database": {
    "enabled": true,
    "ports": [
      8000,
      8001,
      8002
    ],
    "data": [
      [
        "delta",
        "phi"
      ],
      [
        3.14
      ]
    ],
    "temp_targets": {
      "cpu": 79.5,
      "case": 72
    }
  },
  "servers": {
    "alpha": {
      "ip": "10.0.0.1",
      "role": "frontend"
    },
    "beta": {
      "ip": "10.0.0.2",
      "role": "backend"
    }
  }
}
```

すべての有効なJSONは（YAML 1.2以降では）YAMLとしても常に有効なので、このJSONファイルはYAMLとしても有効です。

YAMLではキーや文字列を引用符で囲う必要がなく、コメントを書くことができ、末尾のコンマやより多くのデータ型や値に対応しているので以下のように書くことができます。

```yaml:inline.yaml
# This is a YAML document
{
  title: TOML Example,
  owner: {
    name: Tom Preston-Werner,
    dob: 1979-05-27T07:32:00-08:00,
  },
  database: {
    enabled: true,
    ports: [
      8000,
      8001,
      8002,
    ],
    data: [
      [
        delta,
        phi,
      ],
      [
        3.14,
      ],
    ],
    temp_targets: {
      cpu: 79.5,
      case: 72,
    },
  },
  servers: {
    alpha: {
      ip: 10.0.0.1,
      role: frontend,
    },
    beta: {
      ip: 10.0.0.2,
      role: backend,
    },
  },
}
```

これはYAMLとしては有効ですがJSONとしては無効です。

YAMLにはブロックスタイルとフロースタイルの2つの書き方があり、JSONのような書き方はフロースタイルに該当します。

上記のフロースタイルで書かれたYAMLは以下のブロックスタイルで書かれたYAMLと等しいです。

```yaml:block.yaml
# This is a YAML document
title: TOML Example
owner:
  name: Tom Preston-Werner
  dob: 1979-05-27T07:32:00-08:00
database:
  enabled: true
  ports:
    - 8000
    - 8001
    - 8002
  data:
    - - delta
      - phi
    - - 3.14
  temp_targets:
    cpu: 79.5
    case: 72
servers:
  alpha:
    ip: 10.0.0.1
    role: frontend
  beta:
    ip: 10.0.0.2
    role: backend
```

ブロックスタイルはインデントで文書の構造を表し、フロースタイルは角括弧（`[`と`]`）や波括弧（`{`と`}`）で文書の構造を表します。
従って、フロースタイルの場合は文書を1行だけで書いても文書の構造を問題なく表せます。

以下のように、ブロックスタイルとフロースタイルは混在して書くことができます。

```yaml:mixed.yaml
# This is a YAML document
title: TOML Example
owner:
  name: Tom Preston-Werner
  dob: 1979-05-27T07:32:00-08:00
database:
  enabled: true
  ports:
    - 8000
    - 8001
    - 8002
  data:
    - [delta, phi]
    - [3.14]
  temp_targets:
    cpu: 79.5
    case: 72
servers:
  alpha:
    ip: 10.0.0.1
    role: frontend
  beta:
    ip: 10.0.0.2
    role: backend
```

## 終わりに

フロースタイルを活用することで既存のJSONの見た目を可能な限り維持しながらYAMLの高い表現力を導入できると思いました。
また、ブロックスタイルで読み書きが難しいときに部分的にフロースタイルを活用するとYAMLの読みやすさと書きやすさが向上すると思いました。
