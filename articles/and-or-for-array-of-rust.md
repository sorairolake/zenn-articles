---
title: "Rustの配列の全要素に対して論理積と論理和を取る方法"
emoji: "🦀"
type: "tech"
topics: ["rust"]
published: true
published_at: 2024-04-11 07:00
---

Rustで配列やベクターやスライスの全要素が一致することを調べたい場合、要素が少なければ`(v[0] == v[1]) && (v[1] == v[2])`のように書くことができます。
しかし、要素が多い場合はこの書き方をするのは限界があると思うので、今回は要素が多い場合でもこれができる方法を紹介します。
また、いずれか2つの要素が一致する（論理和）ことを調べる方法も紹介します。

## 要約

次のようなコードであらゆる長さの配列の全要素が一致するかを調べられます。

```rust
let vec = vec![0; 256];
let res = vec.windows(2).all(|v| v[0] == v[1]);
assert!(res);

let arr = [0, 0, 0, 0, 0, 0, 0, 1];
let res = arr.windows(2).all(|v| v[0] == v[1]);
assert!(!res);
```

## 解説

`slice::windows`は指定した個数の要素を持つサブスライスを順に返すイテレータを作成するメソッドです。

https://doc.rust-lang.org/std/primitive.slice.html#method.windows

```rust
let vec: Vec<_> = (0..4).collect();
let mut iter = vec.windows(2);
assert_eq!(iter.next().unwrap(), [0, 1]);
assert_eq!(iter.next().unwrap(), [1, 2]);
assert_eq!(iter.next().unwrap(), [2, 3]);
assert!(iter.next().is_none());
```

`Iterator::all`はイテレータの要素を与えられた関数に渡したときに、全要素が`true`を返すときは`true`を返し、そうでないときは`false`を返すメソッドです。

https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.all

```rust
let slice = &[1, 2, 3, 4];
assert!(slice.iter().all(|&v| v > 0));
assert!(!slice.iter().all(|&v| v > 2));
```

これらのメソッドを組み合わせて、2つの要素を持つサブスライスを比較した結果が全て`true`を返すことを調べることで、結果的に配列の全要素が一致するかを調べることができます。

これらのメソッドを使わない場合は次のようなコードになると思います。

```rust
fn is_all_match(v: &[u8]) -> bool {
    for i in 0..(v.len() - 1) {
        if v[i] != v[i + 1] {
            return false;
        }
    }
    true
}

fn main() {
    assert!(is_all_match(&[0, 0, 0, 0]));
    assert!(!is_all_match(&[0, 0, 1, 1]));
}
```

この例と比較すると、今回紹介した方法はより簡潔にコードを書けると思います。

## 論理和の場合

論理和の場合も今回紹介した方法と似たような方法で配列などのいずれか2つの要素が一致することを確認できます。
ただし、比較にしようするメソッドが異なったり、比較前にソートする必要があるなどの違いがあります。
ただし、比較に使用するメソッドが`Iterator::any`と異なったり、比較前に`slice::sort`などでソートする必要があるなどの違いがあります。

https://doc.rust-lang.org/std/iter/trait.Iterator.html#method.any

https://doc.rust-lang.org/std/primitive.slice.html#method.sort

事前のソートが必要な理由は、一致する要素が存在する場合でも順番がバラバラだと`false`を返す可能性があるからです。
論理積の場合は全要素が一致した場合に`true`を返すので事前のソートは必要ないはずです。

```rust
let mut a = [1, 4, 1, 2];
a.sort();
assert!(a.windows(2).any(|v| v[0] == v[1]));

let mut b: [u8; 4] = (1, 4, 3, 2).into();
b.sort();
assert!(!b.windows(2).any(|v| v[0] == v[1]));
```

## 終わりに

Rustで配列などの全要素に対する論理積（AND）と論理和（OR）の取り方を紹介しました。
配列やベクターの全要素が一致するか調べる必要があることは時々あるように思うので、今回紹介した方法が役立てば幸いです。
