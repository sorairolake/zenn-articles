---
title: "高速な擬似乱数生成器「SFC」について"
emoji: "🎲"
type: "tech"
topics: ["random", "rng", "rust"]
published: true
---

[Zigの標準ライブラリ](https://ziglang.org/documentation/0.13.0/std/#std.Random)を見ていたらSFCという擬似乱数生成器が実装されていて興味を持ったので調べてみました。
ついでにRustで実装してみました。

## SFCとは

SFC（Small Fast Counting、Small Fast Chaotic）は、[PractRand](https://pracrand.sourceforge.net/)の作者のChris Doty-Humphrey氏が設計した擬似乱数生成器（PRNG）です[^1]。
操作は加算、排他的論理和（XOR）、固定幅の論理シフト、固定幅の左ローテートを使用します。
高速で小さいことが特徴で、TestU01のBigCrushを通っています。
sfc16、sfc32、sfc64の3つの擬似乱数生成器が定義されています。
sfc16は主に実験用で、並列使用には不十分であると考えられると述べられています。

|          | sfc32        | sfc64        |
| -------- | ------------ | ------------ |
| 平均周期 | 約$2^{127}$  | 約$2^{255}$  |
| 最小周期 | $2^{32}$以上 | $2^{64}$以上 |
| 内部状態 | 128ビット    | 256ビット    |
| 出力     | 32ビット     | 64ビット     |
| シード   | 96ビット     | 192ビット    |

SFCは[Zigの標準ライブラリ](https://ziglang.org/documentation/0.13.0/std/#std.Random.Sfc64)や[NumPyのBitGenerator](https://numpy.org/doc/2.2/reference/random/bit_generators/sfc64.html)で利用できます。

## 実装

SFCは仕様が単純で簡単に実装できます。
リファレンス実装はPractRandにあり、リファレンス実装のコードとSFCのアルゴリズムの両方が[パブリックドメイン](https://pracrand.sourceforge.net/license.txt)で公開されています。

以下はRustによるsfc32とsfc64の実装例です。

:::message
以下のコードは説明に不要な部分は省いており、そのままではコンパイルできないことに注意してください。
:::

```rust:sfc32.rs
use rand_core::RngCore;

pub struct Sfc32 {
    a: u32,
    b: u32,
    c: u32,
    counter: u32,
}

impl Sfc32 {
    pub fn new(a: u32, b: u32, c: u32) -> Self {
        let mut state = Self {
            a,
            b,
            c,
            counter: 1,
        };
        for _ in 0..12 {
            state.next_u32();
        }
        state
    }
}

impl RngCore for Sfc32 {
    fn next_u32(&mut self) -> u32 {
        const ROTATION: u32 = 21;
        const RIGHT_SHIFT: u32 = 9;
        const LEFT_SHIFT: u32 = 3;

        let tmp = self.a.wrapping_add(self.b).wrapping_add(self.counter);
        self.counter += 1;
        self.a = self.b ^ (self.b >> RIGHT_SHIFT);
        self.b = self.c.wrapping_add(self.c << LEFT_SHIFT);
        self.c = self.c.rotate_left(ROTATION).wrapping_add(tmp);
        tmp
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXPECTED: [u32; 16] = [
        0x5146_76c3,
        0x08a8_09df,
        0x3034_9d2b,
        0xfb52_c520,
        0x3880_2be1,
        0x9482_79e6,
        0xec4b_f1d9,
        0x7cb0_a909,
        0xfad8_b4a8,
        0x3ca4_b808,
        0x3821_b4c5,
        0x5e70_23ca,
        0x50f2_6bf7,
        0xf1e1_b0a2,
        0x6163_032f,
        0x3bf3_c9a4,
    ];

    #[test]
    fn sfc32() {
        let mut rng = Sfc32::new(u32::default(), u32::default(), u32::default());
        for e in EXPECTED {
            assert_eq!(rng.next_u32(), e);
        }
    }
}
```

```rust:sfc64.rs
use rand_core::RngCore;

pub struct Sfc64 {
    a: u64,
    b: u64,
    c: u64,
    counter: u64,
}

impl Sfc64 {
    pub fn new(a: u64, b: u64, c: u64) -> Self {
        let mut state = Self {
            a,
            b,
            c,
            counter: 1,
        };
        for _ in 0..12 {
            state.next_u64();
        }
        state
    }
}

impl RngCore for Sfc64 {
    fn next_u64(&mut self) -> u64 {
        const ROTATION: u32 = 24;
        const RIGHT_SHIFT: u32 = 11;
        const LEFT_SHIFT: u32 = 3;

        let tmp = self.a.wrapping_add(self.b).wrapping_add(self.counter);
        self.counter += 1;
        self.a = self.b ^ (self.b >> RIGHT_SHIFT);
        self.b = self.c.wrapping_add(self.c << LEFT_SHIFT);
        self.c = self.c.rotate_left(ROTATION).wrapping_add(tmp);
        tmp
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const EXPECTED: [u64; 16] = [
        0x3acf_a029_e3cc_6041,
        0xf5b6_515b_f2ee_419c,
        0x1259_6358_94a2_9b61,
        0x0b6a_e753_95f8_ebd6,
        0x2256_2228_5ce3_02e2,
        0x520d_2861_1395_cb21,
        0xdb90_9c81_8901_599d,
        0x8ffd_1953_6521_6f57,
        0xe8c4_ad5e_258a_c04a,
        0x8f8e_f2c8_9fdb_63ca,
        0xf986_5b01_d98d_8e2f,
        0x4655_5871_a65d_08ba,
        0x6686_8677_c629_8fcd,
        0x2ce1_5a7e_6329_f57d,
        0x0b2f_1833_ca91_ca79,
        0x4b08_90ac_9bf4_53ca,
    ];

    #[test]
    fn sfc64() {
        let mut rng = Sfc64::new(u64::default(), u64::default(), u64::default());
        for e in EXPECTED {
            assert_eq!(rng.next_u64(), e);
        }
    }
}
```

加算はリファレンス実装がオーバーフロー時にラップアラウンドするC++で書かれていること、Zigの実装がラップアラウンドする演算子を使っていることから、他のプログラミング言語でもそのようにした方が良いと思います。

公式のテストベクターはないので生成する必要があります。
乱数を生成するにはPractRandの`RNG_output`コマンドが利用できます。
このコマンドのコンパイル方法は<https://pracrand.sourceforge.net/installation.txt>を、使い方は<https://pracrand.sourceforge.net/tools.txt>を参照してください。

例えば、以下はシード値を0にしてsfc64の乱数を128バイト出力します。

```sh
./RNG_output sfc64 128 0 | xxd -i
```

`xxd`コマンドを使っているのは`RNG_output`コマンドで16進ダンプを出力する方法がわからなかったからです。
上記の実装例のテストベクターは`xxd -i`の出力を32ビットの場合は4要素ごとに、64ビットの場合は8要素ごとに整数に変換することで得られます。

なお、SFCのRust実装は`rand_sfc`クレートとして公開しています。

https://crates.io/crates/rand_sfc

## 参考文献

- <https://pracrand.sourceforge.net/RNG_engines.txt>

[^1]: SFCは暗号論的擬似乱数生成器（CSPRNG）ではないので暗号用途での利用には適していません。
