# AdaGB

Adaで開発しているGame Boy Colorエミュレーターです。

現在は開発初期段階で、ウィンドウを表示できます。**ROMの読み込みとゲームの
プレイにはまだ対応していません。**

## 対応環境

macOS向けです。現在はAppleシリコンのMacで動作を確認しています。
Intel MacとmacOS 13.5での動作は未検証です。

## ソースからビルドする

次のツールとライブラリを用意してください。

- AlireとGNAT/GPRbuild
- Xcode Command Line Tools
- SDL2のライブラリとヘッダーファイル（SDL2互換のsdl2-compatも使用できます）
- ソースと初回ビルド時の依存ライブラリを取得するためのインターネット接続

リポジトリを取得してビルドします。

```sh
git clone https://github.com/bubio/AdaGB.git
cd AdaGB
./scripts/build.sh
```

ビルドスクリプトはインストール済みのSDL2を探します。SDL2のインストールや
Homebrewの更新は行いません。SDL2が見つからない場合は、インストール先を
`SDL2_PREFIX`で指定してください。

```sh
SDL2_PREFIX=/opt/local ./scripts/build.sh
```

指定したフォルダに`include/SDL2/SDL.h`と`lib/`が必要です。
実行時にも、ビルドに使用したSDL2ライブラリが必要です。

## 起動する

リポジトリのフォルダで次のコマンドを実行します。

```sh
./bin/adagb
```

「AdaGB」ウィンドウが開き、`No ROM loaded.`と表示されます。
ウィンドウの閉じるボタン、または画面内の`Quit`で終了できます。

使い方とバージョンは次のコマンドで確認できます。

```sh
./bin/adagb --help
./bin/adagb --version
```

ゲームの操作、設定、セーブ機能の案内は、それぞれ実装後に追加します。
