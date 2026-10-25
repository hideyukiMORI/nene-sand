# モジュール構成と依存規則 — NeNe Sand

> Status: normative（規範）/ 2026-10-24 初版
> パッケージ名: `nene-sand`。利用者向けコマンド名も `nene-sand`。

モジュールグラフはアーキテクチャの一部である。承認された一覧の機械可読な正本は `eng/module-graph.txt` で、CNF-011 がそれと `Package.swift` のターゲット依存、および各ファイルの `import` を突き合わせる（ARC-002）。

時刻を読んでよい区画と、ファイルを読んでよい区画は同じ NeNeSandApp である。節は 1 つに畳む。NeNeSandSave は進行と文字列の変換だけで、ファイルを知らない。

NeNeSandSave は空の enum のままである。意味のある型を置く変更で、その空の enum は消す。Core、Render、Terminal、App は砂と水と油と火と木と溶岩と石を持つ。液体の流れは一つの経路で、1段だけ低い隣へは一度だけ動き、引き返さない。2段以上低いときは方向を覚えずに動く。油は水に沈まない。溶岩はその経路を 2 tick に 1 回だけ使う。火は空へ上り、寿命で消える。木は動かない。石は砂と同じ落下で溜まる。火と溶岩と、水が溶岩を石にする反応は `Reaction` の行だけで、上下左右に一度ずつ効く。初めて石ができたら、その印は盤を縮めても残る。自動描画の点列は Core にあり、置くのはマウスと同じ経路である。右クリックもその経路で空を置く。`c` は粒だけを空にし、石が描ける印は残す。`Space` は tick と自動描画を止め、計器に HOLD を出す。筆の正方形は `Brush.cells` で、各マスは今までと同じ `stampCell` に渡す。`m` は自由に遊ぶを切り替え、反応前の石だけを開く。上 3 行と下 3 行は `FramePainter.paint` が `Instrument` に足す。色は `Theme` だけが持つ。`t` で 12 テーマを一周し、粒の色もテーマに属する。水はどのテーマでも青のまま。通貨が増えるのは `Collector.gather` が `Purse.collecting` を呼ぶときだけである。回収口は底の中央の 1 マス。自由に遊ぶでは App が gather を呼ばない。通貨が減るのは `Progression.buying` と `Progression.buyingFaucet` だけである。自動描画の線の終わりは `Progression.advancing` が、その二つを呼ぶ。進行の最初は砂と水。油 40、木 20、溶岩 80。蛇口は 60 で一度だけ買い、持っていると `Faucet.drip` が tick のあと上の中央へ水を 1 粒置く。火は溶岩が油か木を火にしたときだけ `Board.fireKnown` になる。`k` の図鑑は `Codex` が盤の位置へ売値を描く。売値は `Progression.worth` だけが `Price.of` を外へ出す。英語の色見本、目盛、灯、状況、冗談、キーで、左上の日本語の印は無い。計器の行は `stampBrush` が塗らない。座標のずれは `FramePainter.topRows` だけを引く。

---

## 1. 承認されたモジュール

```text
NeNeSandApp
    合成ルート。製品名の実行ファイルは nene-sand。
    時計、乱数源、端末、セーブファイルを組み立てる。
    端末出力と終了コードを持つ唯一の場所

NeNeSandTerminal
    セル格子を ANSI の差分として書く。termios、SIGWINCH、キーとマウスを解析する。
    Glibc を import してよい唯一のライブラリ。時刻と乱数は読まない

NeNeSandRender
    盤面から文字セルの格子を作る。端末を知らない。Save を知らない

NeNeSandSave
    進行の値と、版つきセーブ文字列を往復する。ファイルを知らない。Render を知らない

NeNeSandCore
    盤面、物質、反応、1 tick、入力の適用、進行の状態遷移。
    時刻、乱数源、端末、Foundation、ファイルを知らない
```

---

## 2. 許可された依存グラフ

```text
NeNeSandCore
    -> 言語標準のうち、グラフが許した import だけ（現在は 0）

NeNeSandSave
    -> NeNeSandCore

NeNeSandRender
    -> NeNeSandCore

NeNeSandTerminal
    -> NeNeSandRender
    -> Glibc

NeNeSandApp
    -> NeNeSandCore, NeNeSandSave, NeNeSandRender, NeNeSandTerminal
    -> Foundation, Glibc
```

ここに無い依存は禁止である。とくに:

- Core から Save / Render / Terminal / App へ: 禁止
- Save と Render の相互依存: 禁止
- Terminal から Save へ: 禁止
- どのライブラリからも App へ: 禁止
- Foundation を App 以外が import すること: 禁止
- Dispatch を誰かが import すること: 禁止（SWF-013）

---

## 3. 各モジュールの責務

### `NeNeSandCore`

意味の正本を持つ。物質は閉じた enum、反応は 1 行 1 反応の表、になる予定である。現在時刻とファイルを持たない。

### `NeNeSandSave`

進行と版つき文字列の符号変換だけを持つ。

### `NeNeSandRender`

盤面をセルの値へ写す。配色表はここだけが持つ。

### `NeNeSandTerminal`

Glibc の termios / ioctl / signal を薄く包む。決定性の禁止は免除しない。マウス報告は終了時に必ず解除する。標準入力のフラグも、開始時の値へ戻す。

### `NeNeSandApp`

時刻ポートとファイルポートの実装を持つ。決定性の禁止を適用しない唯一のモジュールであり（ARC-007）、セーブファイルの読み書きもここに閉じる（ARC-009）。コマンド名 `nene-sand` はこのターゲットから作る。モジュール名にハイフンは使えないので、ターゲット名は NeNeSandApp である。

---

## 4. ソースの置き場

| 種類 | 置き場 |
| --- | --- |
| production | `Sources/<ターゲット>/` |
| 製品テスト | `Tests/`。振る舞いが無いので、まだ置かない。枠組みは Swift Testing（ADR 0002） |
| 検査設定 | `.swift-version`、`.swift-format`、`.swiftlint.yml`、`eng/tool-versions.txt`、`eng/module-graph.txt`。CNF-007 が参照を見る |
| 規約検査 | `eng/conformance.py` と `eng/test_conformance.py`。テストは製品ソースの検査対象外 |
| 生成コード | 無い。生成を足すときは生成場所を宣言し、手で編集しない |
