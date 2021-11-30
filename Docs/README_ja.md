# Ranasa: arm64バイナリのアーキテクチャを選択する

![swift 5.3](https://img.shields.io/badge/swift-5.3-orange.svg)
![platform macOS](https://img.shields.io/badge/platform-macOS-blue)
![SPM supported](https://img.shields.io/badge/SPM-supported-green)

![logo image](logo.png)

ライブラリのarm64バイナリがリンクされるアーキテクチャを選択するためのmacOSユーティリティです。
このツールはDMM.comの業務中に開発されました。


## 詳細

`Ranasa`は`darrarski/xcframework-maker` に触発されて作成されたツールです。

`xcframework-maker`ではFat-ArchitectureのFrameworkに対してXCFramework化し、合わせてarm64-simに対応したFrameworkを同時に生成することができます。これに対して`Ranasa` ではスタティックライブラリやダイナミックライブラリに対してarm64-simに対応させるアプローチを提供します。スタティックライブラリでは`ar archive`にてまとめられたもの、ダイナミックライブラリではそのまま適する形でarm64-simをリンクするように命令される部分を書き換えます。

これを実現する基礎技術としてClangが関わってきます。読み込むバイナリのヘッダーファイルが特定の場合にはClangがリンクする対象を実機向けとシミュレータ向けに選択する挙動を行います。本ツールではこれを操作するためのスタティックライブラリとダイナミックライブラリに対して共通のインターフェイスを提供します。

## 議論

なぜ別のツールが必要なのでしょうか。理由として既存のワークフローをできる限りそのままにアプリケーションの保守ができるためです。このツールが使いたいプロジェクトとは過去から引き継いできた歴史のあるアプリケーションが多いと推測しています。そのため新しいパッケージを提供するツールを無理やり使ってarm64-sim対応を行うと既存のプロジェクトの組み方を変更する観点から新規調査を始めなくてはなりません。

また直接ライブラリを使っているプロジェクトに対してそれぞれフレームワークにまとめる必要が発生します。これは非常に面倒な作業です、できる限りやりたくないです。ただ単にApple Silicon搭載のMacでarm64でXcodeを使って開発したいだけなのに多くの時間や手間を書けるのは非常に時間やリソースの調整が必要です、PdM側から見るとRosetta2経由で動かせるなら工数を割かない判断をすることも合理的とすら思えます。


DMM.comのチームでは開発・保守を行っているアプリがいくつかあります。そのうちの一つのアプリではまさに上記の課題に直面していたため必要に駆られてこのユーティリティを作成しました。

## 参考

スタティックライブラリの書き換え

https://bogo.wtf/arm64-to-sim.html

ダイナミックライブラリの書き換え

https://bogo.wtf/arm64-to-sim-dylibs.html

実装リポジトリ

https://github.com/bogo/arm64-to-sim

## ビルド方法

Swift 5.3以上を使えるmacOSにてビルド出来ます。

```shell
swift build -c release
```

出力された成果物は実行ファイルとなっているため通常のCLIアプリケーションと同じように扱えます。

```shell
.build/release/ranasa
```

Xcodeのビルドスクリプトで実行したい場合にはプロジェクトの`Package.swift`に`Ranasa`の依存を追加してコマンドを発行すると利用できます。

```shell
xcrun --sdk macosx swift run -c release ranasa
```

## 使い方

```text
$ ranasa -h
OVERVIEW: `ranasa` is utility for switch architecture from legacy static library, static framework, dynamic library, dynamic framework.

The design idea is to make binary libraries that depend on projects built with
older designs compatible with Apple Silicon from the outside.

For libraries that are Fat Architecture Binary,
we can change them from arm64 and x86_64-simulator to arm64 and arm64-simulator
and build them with arm64-Xcode and run them on arm64-simulator.
You can build it with arm64-Xcode and run it on arm64-simulator.

This tool can be recommended for projects that for some reason cannot support the xcframework,
or where changing the packaging of the library would increase the man-hours.

Input File Description
- linking: type `static` or `dynamic`.
- path: relative path, Source Root define `root` option.

"""
[
    {
        "linking": "dynamic",
        "path":  "relative/path/to/library"
    },
    {
        "linking": "static",
        "path":  "relative/path/to/framework/in/library"
    },
]
"""

USAGE: ranasa <config-file> [--root <root>] [--store <store>] [--minos <minos>] [--sdk <sdk>] [--xcode] [--simulator] [--verbose] [--check]

ARGUMENTS:
  <config-file>           Path of the definition file

OPTIONS:
  -r, --root <root>       The location to root the library  (default: .)
  -s, --store <store>     The location to store save the binary (default: ${HOME}/.ranasa/)
  --minos <minos>         Simulator minos variable number (default: 13)
  --sdk <sdk>             Simulator sdk variable number (default: 13)
  -x, --xcode             If in xcode script, auto detect simulator or actual. fall back to `simulator` flag.
  -a, --simulator         Replace binaries with simulator builds
  -v, --verbose           Log detailed info to standard output.
  -c, --check             Display how ranasa recognizes the descriptions in the configuration file.
        Does not cause side effects. Only outputs the configuration file.
  -h, --help              Show help information.
```

### Example

jsonファイルに必要な情報を定義する。

```json
[
    {
        "linking": "dynamic",
        "path": "/path/to/library"
    },
    {
        "linking": "static",
        "path": "/path/to/library"
    }
]
```

`Ranasa`をXcodeのビルドスクリプトで実行します。
`Ranasa`がSDKROOTを参照して自動で適したバイナリを配置します。

```shell
ranasa -x <setting.json>
```

## コミッター

Main Author: [@arasan01](https://github.com/arasan01)

Supported: [DMM.com](https://inside.dmm.com/)

## メンテナンスについて

本アプリケーションは @arasan01 がDMM.comにてiOS開発チーム内利用を目的として独自で作成したものをOSS化しました。
そのため [@arasan01](https://github.com/arasan01) がDMM.comにて開発に関わっている間のメンテナンスは行っていきます。

もし何らかの事情により保守がされなくなった場合に、継続して利用したいユーザによる開発・保守を希望する場合はIssueで正式なFork先を提案してください。READMEに移行先を記載します。


## 貢献

Pull RequestかIssueにて提案してください。

## ライセンス

Copyright 2021 DMM.com LLC.
Licensed under the MIT License.

## 採用活動

DMM.comではモバイルアプリ開発者の採用を強化しています。

私達と一緒にDMMで開発をしませんか？

興味があれば気軽にお話しましょう！

DMMエンジニア採用

https://dmm-corp.com/recruit/engineer/
