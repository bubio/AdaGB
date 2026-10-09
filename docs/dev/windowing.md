# ウィンドウ表示の実装と検証

## 検討コードから取り込んだ内容

`~/dev/_Emu/_SandBox/ada_imgui_test`のSDL2 / Dear ImGui接続を基にしています。

- Ada側でImGuiコンテキスト、UI、イベントループを管理します。
- `src/sdl_backend.cpp`がSDL初期化・終了、ウィンドウ、レンダラー、イベント転送を担当します。
- `src/gui_buttons.*`は`df_imgui 0.1.0`のボタン用Vec2を`C_Pass_By_Copy`で値渡しします。
- ウィンドウ表示に不要なSDLAdaおよびSDL_image/mixer/ttfへの依存は追加していません。

ウィンドウはリサイズと高DPI表示に対応しています。設定ファイル・セーブ機能は
未実装です。現在は`imgui.ini`を作りません。

## 依存ライブラリ

Alireで`df_imgui = 0.1.0`を取得します。初回ビルドでは依存側のpost-fetch
スクリプトでcimguiをビルドします。

`vendor/imgui_backends/`は検討コードで使用したDear ImGui **1.92.9 WIP**の
公式SDL2 / SDLRenderer2バックエンドです。`df_imgui 0.1.0`の取得元コミット
`3dec19e9896a15f1194c8c98dc7848324c0faaac`と同じ版であり、MITライセンスを
同梱しています。依存を更新するときはバックエンドも同じ版に揃えてください。

## ビルドと対象OS

開発環境とCIでは共通の`./scripts/build.sh`を使用します。
SDL2は既存のシステムライブラリに動的リンクします。

ローカルビルドの対象OSは実行中のmacOSに合わせます。
SDKのバージョンが実行ファイルの最低対象OSとして使われ、アプリとして
起動できなくなる問題を避けるための設定です。

`MACOSX_DEPLOYMENT_TARGET`で対象OSを変更できますが、依存ライブラリと
GNATランタイムも対象OSに対応している必要があります。今回の検証環境の
SDL2はmacOS 27向け、GNATランタイムはmacOS 15向けのため、仕様にある
macOS 13.5対応は未検証です。

## 起動・描画テスト

```sh
./scripts/build.sh
./bin/adagb --frames 120
```

`--frames`には正のフレーム数を指定します。指定したフレーム数だけ描画した後、
バックエンドとSDLを終了し、ImGuiコンテキストを解放します。
正常終了時には`Rendered frames: 120`のように出力します。

## 検証結果

macOS arm64で次の動作を確認しました。

- ビルドと120フレームの描画・正常終了
- 実画面の表示
- `Quit`とmacOSの閉じるボタンによる終了
- ヘルプ・バージョン表示
- 不正な引数の失敗終了
- SDL初期化エラーの診断と失敗終了

画面操作ツールによる確認では、ビルドした実行ファイルを一時的なアプリバンドルに
格納しました。このバンドルは`bin/`内の検証用生成物で、配布用ではありません。
Intel Macおよび古いmacOSでの実行は未検証です。

開発仕様は[spec_input.md](spec_input.md)にあります。
