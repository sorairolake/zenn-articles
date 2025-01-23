---
title: "Rust 1.84からRustの最小バージョンを考慮した依存関係の解決ができるようになった"
emoji: "📦"
type: "tech"
topics: ["cargo", "rust"]
published: true
---

[Rust 1.84](https://blog.rust-lang.org/2025/01/09/Rust-1.84.0.html)でRustの最小バージョン（MSRV）を考慮するリゾルバが安定化されました。
これによって、`cargo add`で間接的に追加されるクレートのMSRVが考慮されるようになったり、`cargo update`で`rust-version`フィールドで指定されているRustのバージョンと互換性のあるバージョンのクレートが自動的に選択されるようになります。

```sh
cargo add clap
```

![MSRVを考慮した依存関係の解決](/images/introduce-msrv-aware-resolver/msrv-aware-cargo-add.webp)
_MSRVを考慮した依存関係の解決_

![MSRVを考慮しない依存関係の解決](/images/introduce-msrv-aware-resolver/msrv-unaware-cargo-add.webp)
_MSRVを考慮しない依存関係の解決_

```sh
cargo update
```

![MSRVを考慮した依存関係の解決](/images/introduce-msrv-aware-resolver/msrv-aware-cargo-update.webp)
_MSRVを考慮した依存関係の解決_

![MSRVを考慮しない依存関係の解決](/images/introduce-msrv-aware-resolver/msrv-unaware-cargo-update.webp)
_MSRVを考慮しない依存関係の解決_

MSRVは（間接的に）依存するクレートで`rust-version`フィールドが定義されている場合に考慮されます。
このフィールドが定義されていない依存するクレートではMSRVを考慮した依存関係の解決は行われません。

## 設定方法

MSRVを考慮した依存関係の解決は`.cargo/config.toml`で次のように設定することで有効になります。

```toml:.cargo/config.toml
[resolver]
incompatible-rust-versions = "fallback"
```

また、`Cargo.toml`で次のように設定することでも有効になります。

```toml:Cargo.toml
[package]
# ...
resolver = "3"
```

なお、Rust 1.85で安定化予定の[Rust 2024](https://doc.rust-lang.org/edition-guide/rust-2024/index.html)からは`package.resolver = "3"`がデフォルトで有効になるので、上記の設定をしなくてもMSRVを考慮した依存関係の解決が行われます。

## 終わりに

今までは`cargo update`を実行するとMSRVの互換性のないクレートが選択されて困っていましたが、MSRVを考慮するリゾルバが安定化されたことでこの問題が解決するので個人的に非常に助かります。
