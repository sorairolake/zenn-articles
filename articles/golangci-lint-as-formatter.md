---
title: "golangci-lintにコードフォーマットのためのコマンドが追加された"
emoji: "🐁"
type: "tech"
topics: ["formatter", "go"]
published: true
---

数日前に[`golangci-lint`](https://golangci-lint.run/) v2がリリースされました。

https://ldez.github.io/blog/2025/03/23/golangci-lint-v2/

`golangci-lint` v2ではコードをフォーマットするための`golangci-lint fmt`コマンドが追加されました。

次のコマンドを実行することでプロジェクトの全てのGoファイルをフォーマットできます。

```sh
golangci-lint fmt
```

次のように指定したディレクトリやファイルだけを対象とすることもできます。

```sh
# `cmd`ディレクトリ以下のGoファイルを再帰的にフォーマット
golangci-lint fmt cmd/...
# `main.go`をフォーマット
golangci-lint fmt main.go
```

`golangci-lint fmt`は`gofmt`や`goimports`などのコードフォーマッタを組み合わせてコードをフォーマットします。
使用するフォーマッタは設定ファイルかコマンドのオプションで設定できます。

https://golangci-lint.run/usage/configuration/#formatters-configuration

例えば、次のように設定したときは`gofmt`と`goimports`がコードフォーマッタとして使用されます。

```toml:.golangci.toml
version = "2"

[formatters]
enable = ["gofmt", "goimports"]
```

現時点では次のコードフォーマッタが利用できます。

- [`gci`](https://github.com/daixiang0/gci)
- [`gofmt`](https://pkg.go.dev/cmd/gofmt)
- [`gofumpt`](https://github.com/mvdan/gofumpt)
- [`goimports`](https://pkg.go.dev/golang.org/x/tools/cmd/goimports)
- [`golines`](https://github.com/segmentio/golines)

利用可能なコードフォーマッタは`golangci-lint help formatters`または`golangci-lint formatters`でも確認できます。

```sh
$ golangci-lint help formatters
Disabled by default formatters:
gci: Checks if code and import statements are formatted, with additional rules.
gofmt: Checks if the code is formatted according to 'gofmt' command.
gofumpt: Checks if code and import statements are formatted, with additional rules.
goimports: Checks if the code and import statements are formatted according to the 'goimports' command.
golines: Checks if code is formatted, and fixes long lines.
```

```sh
$ golangci-lint formatters
Enabled by your configuration formatters:
gofmt: Checks if the code is formatted according to 'gofmt' command.
goimports: Checks if the code and import statements are formatted according to the 'goimports' command.

Disabled by your configuration formatters:
gci: Checks if code and import statements are formatted, with additional rules.
gofumpt: Checks if code and import statements are formatted, with additional rules.
golines: Checks if code is formatted, and fixes long lines.
```

`formatters`で指定したコードフォーマッタは`golangci-lint run`を実行するときに自動的にlinterとして使用されます。
つまり、`golangci-lint` v1でこれらのコードフォーマッタを有効にしたときと同じように動作します。

いずれのフォーマッタも有効にしていないときは標準的なGoのスタイルが使用されます。

## 例

次のコードはフォーマット前のコードです。

```go:main.go
package main

import (
        "github.com/zeebo/blake3"
        "fmt"
)

func main(){
        data := []byte("Hello, world!")
        sum:=blake3.Sum256(data)
        fmt.Printf("%x\n", sum)
}
```

これを上記の設定と同じく`gofmt`と`goimports`を有効にして`golangci-lint fmt`を実行すると次のようにフォーマットされます。

```go:main.go
package main

import (
        "fmt"

        "github.com/zeebo/blake3"
)

func main() {
        data := []byte("Hello, world!")
        sum := blake3.Sum256(data)
        fmt.Printf("%x\n", sum)
}
```

フォーマット前とフォーマット後の差分は`golangci-lint fmt --diff`を実行すると見ることができます。

```diff go
diff b3sum/main.go.orig b3sum/main.go
--- b3sum/main.go.orig
+++ b3sum/main.go
@@ -1,12 +1,13 @@
 package main

 import (
-       "github.com/zeebo/blake3"
        "fmt"
+
+       "github.com/zeebo/blake3"
 )

-func main(){
+func main() {
        data := []byte("Hello, world!")
-       sum:=blake3.Sum256(data)
+       sum := blake3.Sum256(data)
        fmt.Printf("%x\n", sum)
 }
```

コードがフォーマットされているかは`golangci-lint run`を実行すると確認できます。

フォーマット前:

```sh
$ golangci-lint run
        "github.com/zeebo/blake3"
^
1 issues:
* gofmt: 1
```

フォーマット後:

```sh
$ golangci-lint run
0 issues.
```

終了コードに基づいてフォーマット済みかを確認する場合、`golangci-lint fmt --diff`も`golangci-lint run`もフォーマット前のときは非ゼロを返し、フォーマット後のときはゼロを返すのでこれが利用できます。
ただし、`golangci-lint run`はフォーマット済みでも他のlinterがエラーを返すときは非ゼロを返します。

## 参考文献

- <https://golangci-lint.run/usage/configuration/>
- <https://golangci-lint.run/usage/formatters/>
- <https://github.com/golangci/golangci-lint/issues/5601>
