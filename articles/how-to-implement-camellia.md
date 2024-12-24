---
title: "ZigでCamelliaブロック暗号を実装する"
emoji: "🌸"
type: "tech"
topics: ["camellia", "cryptography", "rfc", "zig"]
published: true
---

## はじめに

最近、[Zig](https://ziglang.org/)で[Camellia](https://info.isl.ntt.co.jp/crypt/camellia/)ブロック暗号を実装しました。

https://github.com/sorairolake/camellia-zig

3年近く前にCamelliaのRust実装の[`camellia`](https://crates.io/crates/camellia)クレートを書きましたが、最近はZigも少し書くようになったのでZigでも実装してみたいと思って実装しました。

この記事では、上記の実装を参照しながらCamelliaを実装する方法について述べたいと思います。

## Camelliaについて

[Camellia](https://ja.wikipedia.org/wiki/Camellia)は、2000年にNTTと三菱電機によって開発されたブロック暗号です。
CamelliaのインターフェースはAES互換で、ブロック長は128ビット、鍵長は128ビット、192ビット、256ビットです。
CamelliaはAESと同等の安全性と処理性能を有しており、AESと同じく[CRYPTREC](https://www.cryptrec.go.jp/)の電子政府推奨暗号リストに載っています。

Camelliaのアルゴリズムは[RFC 3713](https://datatracker.ietf.org/doc/html/rfc3713)で説明されています。
RFCの[日本語訳](https://www.nic.ad.jp/ja/tech/ipa/RFC3713JA.html)もあります。

## 実装

RFCで仕様が説明されているので、そのとおりに実装すれば暗号化と復号ができます。

Camelliaでは鍵スケジュール部で与えられた鍵から副鍵を生成して、生成した副鍵を使って暗号化と復号を行います。

### 定数

Camelliaではマスク用の定数値`MASK8`、`MASK32`、`MASK64`、`MASK128`が定義されています。
今回の実装では`MASK8`、`MASK128`は使用しないので実装内で定義していません。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/camellia.zig#L16-L20

### 鍵スケジュール

鍵スケジュール部では与えられた鍵`K`から暗号化と復号に使用する副鍵を生成します。

鍵スケジュール部では128ビット変数の`KL`、`KR`、`KA`、`KB`を使用します。

`KL`、`KR`は鍵`K`から生成します。
Camellia-128の場合は128ビット鍵`K`を`KL`として使用し、`KR`には0を設定します。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/camellia.zig#L187-L189

RFCにはバイトオーダーについて書かれていませんが、[アルゴリズム仕様書](https://info.isl.ntt.co.jp/crypt/camellia/dl/01jspec.pdf)にバイトオーダーがビッグエンディアンあると書かれているので`K`をビッグエンディアンで読み取ります。

Camellia-192の場合は192ビット鍵`K`の上位128ビットを`KL`として使用し、`K`の下位64ビットを64桁左シフトした値と`K`の下位64ビットをビット反転した値の論理和を`KR`として使用します。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/camellia.zig#L194-L197

Camellia-256の場合は256ビット鍵`K`の上位128ビットを`KL`として使用し、`K`の下位128ビットを`KR`として使用します。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/camellia.zig#L203-L205

`KA`、`KB`は`KL`、`KR`から生成します。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/camellia.zig#L91-L109

`KA`、`KB`の生成時に使用する64ビット定数`Sigma1`から`Sigma6`は以下のように定義されています。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/consts.zig#L7-L23

副鍵はこれらの変数を左循環シフトした結果の上位64ビットか下位64ビットを使用して生成します。

Camellia-128の場合は`KL`、`KA`を使用して64ビットの副鍵`kw`（ホワイトニングで使用）4個、`k`（ラウンド鍵）18個、`ke`（6ラウンドごとに使用）4個の計26個生成します。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/camellia.zig#L111-L143

Camellia-192、Camellia-256の場合は`KL`、`KR`、`KA`、`KB`を使用して64ビットの副鍵`kw`（ホワイトニングで使用）4個、`k`（ラウンド鍵）24個、`ke`（6ラウンドごとに使用）6個の計34個生成します。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/camellia.zig#L145-L185

Zigで左循環シフトは[`std.math.rotl`](https://ziglang.org/documentation/0.13.0/std/#std.math.rotl)でできます。

### 暗号化

暗号化では最初に128ビットの平文`M`を上位64ビットの`D1`と下位64ビットの`D2`に分割します。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/camellia.zig#L239-L240

18ラウンド（Camellia-128）または24ラウンド（Camellia-192、Camellia-256）のFeistel構造を使って行います。
6ラウンドごとにFL関数とFLINV関数を挿入します。

128ビットの暗号文`C`は`D2`を64桁左シフトした値と`D1`の論理和です。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/camellia.zig#L233-L260

### 復号

復号は副鍵の順序を反転させて暗号化と同じ処理をすることで行えます。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/camellia.zig#L284-L311

### コンポーネント

#### F関数

ラウンド関数Fは<https://datatracker.ietf.org/doc/html/rfc3713#section-2.4.1>で説明されています。
今回の実装ではRFCのものよりも高速に処理できることから[Botan](https://botan.randombit.net/)のF関数を利用しています。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/camellia.zig#L22-L53

Camelliaでは4つのS-boxを使用します。
`SBOX1`は以下のように定義されています。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/consts.zig#L25-L43

`SBOX2`から`SBOX4`は以下の式で求めることができます。

```zig
sbox_2[x] = math.rotl(u8, sbox_1[x], 1);
sbox_3[x] = math.rotl(u8, sbox_1[x], 7);
sbox_4[x] = sbox_1[math.rotl(u8, x, 1)];
```

今回の実装では`SBOX2`から`SBOX4`は事前に計算したものを使用しています。

#### FL関数とFLINV関数

FL関数とFLINV関数は<https://datatracker.ietf.org/doc/html/rfc3713#section-2.4.2>で説明されています。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/camellia.zig#L55-L79

## テスト

<https://datatracker.ietf.org/doc/html/rfc3713#appendix-A>にテストベクターがあるのでこれで正しく実装できたか検証できます。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/camellia.zig#L517-L548

また、<https://info.isl.ntt.co.jp/crypt/eng/camellia/dl/cryptrec/t_camellia.txt>により大きなテストベクターがあります。
今回の実装ではこのテストベクターをYAMLにして、それをZigの標準ライブラリで読み取れるJSONに変換してテストしています。

https://github.com/sorairolake/camellia-zig/blob/v0.1.0/src/tests/camellia_128.zig#L5-L46

## 終わりに

Zig以外のプログラミング言語でも上記のようにRFCに従ったコードを書くことでCamelliaを実装できます。
Zigは128ビット整数型がプリミティブ型なので他のプログラミング言語よりも簡単に実装できるように思いました。
