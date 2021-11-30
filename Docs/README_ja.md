# アレフガルド: arm64バイナリのアーキテクチャを選択する

![swift 5.3](https://img.shields.io/badge/swift-5.3-orange.svg)
![platform macOS](https://img.shields.io/badge/platform-macOS-blue)
![SPM supported](https://img.shields.io/badge/SPM-supported-green)

![logo image](Docs/logo.png)

ライブラリのarm64バイナリがリンクされるアーキテクチャを選択するためのmacOSユーティリティです。
このツールはDMM.comの業務中に開発されました。


## 詳細

`アレフガルド`  は  `darrarski/xcframework-maker` に触発されて作成されたツールです。
`xcframework-maker`ではFat-ArchitectureのFrameworkに対してXCFramework化し、合わせてarm64-simに対応したFrameworkを同時に生成することができます。これに対して `アレフガルド` ではスタティックライブラリやダイナミックライブラリに対してarm64-simに対応させるアプローチを提供します。スタティックライブラリでは`ar archive`にてまとめられたもの、ダイナミックライブラリではそのまま適する形でarm64-simをリンクするように命令される部分を書き換えます。
これを実現する基礎技術としてClangが関わってきます。読み込むバイナリのヘッダーファイルが特定の場合にはClangがリンクする対象を実機向けとシミュレータ向けに選択する挙動を行います。本ツールではこれを操作するためのスタティックライブラリとダイナミックライブラリに対して共通のインターフェイスを提供します。

## 議論

なぜ別のツールが必要なのでしょうか。理由として既存のワークフローをできる限りそのままにアプリケーションの保守ができるためです。このツールが使いたいプロジェクトとは過去から引き継いできた歴史のあるアプリケーションが多いと推測しています。そのため新しいパッケージを提供するツールを無理やり使ってarm64-sim対応を行うと既存のプロジェクトの組み方を変更する観点から新規調査を始めなくてはなりません。また直接ライブラリを使っているプロジェクトに対してそれぞれフレームワークにまとめる必要が発生します。これは非常に面倒な作業です、できる限りやりたくないです。ただ単にApple Silicon搭載のMacでarm64でXcodeを使って開発したいだけなのに多くの時間や手間を書けるのは非常に時間やリソースの調整が必要です、PdM側から見るとRosetta2経由で動かせるなら工数を割かない判断をすることも合理的とすら思えます。
DMM.comのチームでは開発・保守を行っているアプリがいくつかあります。そのうちの一つのアプリではまさに上記の課題に直面していたため必要に駆られてこのユーティリティを作成しました。

スタティックライブラリの書き換え
https://bogo.wtf/arm64-to-sim.html

ダイナミックライブラリの書き換え
https://bogo.wtf/arm64-to-sim-dylibs.html

## ビルド方法

Swift 5.3以上を使えるmacOSにてビルド出来ます。
```shell
swift build -c release
```

出力された成果物は実行ファイルとなっているため通常のCLIアプリケーションと同じように扱えます。
```shell
.build/release/alefgard
```

Xcodeのビルドスクリプトで実行したい場合にはプロジェクトの`Package.swift`に`Alefgard`の依存を追加してコマンドを発行すると利用できます
```shell
xcrun --sdk macosx swift run -c release alefgard
```

## 使い方

後でコードを書き終わったらhelpを乗せる

```
```

Example

jsonファイルに必要な情報を定義する。

```json
```

`Alefgard`をXcodeのビルドスクリプトで実行する
後でシミュレータ分岐の処理をビルドスクリプトに追記する

```shell
xcrun --sdk macosx swift run -c release alefgard
```

## コミッター

メイン作成者: @arasan01
DMM iOS開発者一同

## メンテナンスについて

本アプリケーションは @arasan01 がDMM.comにてiOS開発チーム内利用を目的として独自で作成したものをOSS化しました。
そのため @arasan01 がDMM.comにて開発に関わっている間のメンテナンスは行っていきます。
もし何らかの事情により保守がされなくなった場合に、継続して利用したいユーザによる開発・保守を希望する場合はIssueで正式なFork先を提案してください。READMEに移行先を記載します。


## 貢献

後で相談する

## ライセンス

Copyright 2021 DMM.com LLC.
Licensed under the MIT License.

## 採用活動

DMM.comではモバイルアプリ開発者の採用を強化しています。
私達と一緒にDMMで開発をしませんか？
興味があれば気軽にお話しましょう！

DMMエンジニア採用
https://dmm-corp.com/recruit/engineer/
