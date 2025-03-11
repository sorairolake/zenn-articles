---
title: "ライブラリクレートでは`doc_cfg`や`doc_auto_cfg`を有効にするのがおすすめ"
emoji: "🦀"
type: "tech"
topics: ["rust"]
published: true
---

rustdocで[`doc_cfg`](https://doc.rust-lang.org/rustdoc/unstable-features.html#doccfg-recording-what-platforms-or-features-are-required-for-code-to-be-present)機能や[`doc_auto_cfg`](https://doc.rust-lang.org/rustdoc/unstable-features.html#doc_auto_cfg-automatically-generate-doccfg)機能を有効にすると、条件付きコンパイルに関する情報を`rustdoc`に伝えることができます。
これらの機能を有効にすると、以下のようにそのアイテムが特定のfeatureフラグが有効な場合や特定のプラットフォームでのみ利用可能なことを説明するバナーを表示できます。

![表示結果](/images/display-features-in-rustdoc/hf.webp)
_`unix`モジュールはUnix環境でのみ利用可能_

![表示結果](/images/display-features-in-rustdoc/nt-time.webp)
_`now`メソッドは`std`フラグが有効な場合のみ利用可能_

## 設定方法

これらの機能はまだ不安定なので`cfg_attr`を使って`docsrs`が定義されている場合にのみ機能を有効にします。

```rust:src/lib.rs
#![cfg_attr(docsrs, feature(doc_cfg))]
// または
#![cfg_attr(docsrs, feature(doc_auto_cfg))]
```

`doc_cfg`機能が有効な場合に`unix`モジュールにバナーを表示するには以下のようにします。

```rust:src/lib.rs
#[cfg(unix)]
#[cfg_attr(docsrs, doc(cfg(unix)))]
pub use crate::platform::unix;
```

`doc_auto_cfg`機能が有効な場合に`now`メソッドにバナーを表示するには以下のようにします。

```rust:src/lib.rs
#[cfg(feature = "std")]
pub fn now() -> Self {
    ...
}
```

`doc_auto_cfg`機能は`doc_cfg`機能を拡張した機能で、`doc(cfg(...))`を追加しなくても自動的にバナーを表示できます。

多くの場合はこれらの機能は機能しますが、以下のように`cfg_attr`を使用して特定のfeatureフラグが有効な場合にのみトレイトを導出する場合は現時点ではバナーは表示されません。

```rust:src/lib.rs
#[cfg_attr(feature = "serde", derive(serde::Serialize))]
pub struct Params {
    ...
}
```

https://github.com/rust-lang/rust/issues/103300

## docs.rsでバナーを表示する

[docs.rs](https://docs.rs/)でバナーを表示するには以下のようにします。

```toml:Cargo.toml
[package.metadata.docs.rs]
# 全てのfeatureフラグを有効にできない場合は適宜変更する
all-features = true
# `cfg`が`docsrs`の場合は不要
rustdoc-args = ["--cfg", "docsrs"]
```

docs.rsでは既定の`cfg`として[`docsrs`](https://docs.rs/about/builds#detecting-docsrs)が定義されるので、`cfg`が`docsrs`の場合は`rustdoc-args`は不要です。

## ローカル環境でバナーを表示する

ローカル環境でバナーを表示するには以下のように`RUSTDOCFLAGS`環境変数に`--cfg cfg`を設定して[`cargo doc`](https://doc.rust-lang.org/cargo/commands/cargo-doc.html)を実行します。

```sh
env RUSTDOCFLAGS="--cfg docsrs" cargo +nightly doc --all-features
```
