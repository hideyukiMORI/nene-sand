# アーキテクチャ憲章 — NeNe Sand

> Status: normative（規範）/ 2026-10-24 初版
> 判断の根拠は [ADR 0001](adr/0001-strictness-is-mechanically-enforced.md)。
> 本書が沈黙している領域は [CODING_RULES.md](CODING_RULES.md) と Swift 6 の標準に従う。

---

## 0. この文書の読み方

**すべての規則は「機械強制」の状態を持つ。**

| 表記 | 意味 |
| --- | --- |
| **active** | 違反すると `make check` が落ちる。人の記憶に依存しない |
| **planned** | 規範だが、まだ機械が見ていない。この行に触れる変更は PR で明示的に自己レビューする |
| **不能** | 言語・道具の仕様上、機械では塞げない。塞げないことを明記して残す |
| **不採用** | 検討して採らなかった。理由を必ず併記する |

正本は [QUALITY_GATES.md](QUALITY_GATES.md) の強制マトリクスであり、文書整合検査が「本書に定義があるのにマトリクスに行が無い」状態と、本文の機械強制とマトリクスの状態の食い違いを拒否する。

### 強制の実体は 5 層ある

| 層 | 実体 | 守るもの |
| --- | --- | --- |
| コンパイラ | Swift 6 言語モード、`-warnings-as-errors` | 網羅漏れ・未初期化・可視性・警告 |
| ビルドのモジュールグラフ | `eng/module-graph.txt` と `Package.swift` | 層の依存方向 |
| API 単位の禁止 | 字句検査（CNF-010） | 時刻・乱数・環境・Task / Dispatch |
| 静的解析 | swift-format 6.4.1、SwiftLint 0.65.1 の名指し規則 | 整形・複雑度・強制アンラップ |
| 規約検査 | `eng/conformance.py`（Python 標準ライブラリだけ） | NeNe Sand として守るべきこと |

### Swift 6.4.1 がどこまで届いたか

本リポジトリの列は 2026-10-24 の実測（Swift 6.4.1、glibc 2.35、x86_64-unknown-linux-gnu）。先行 5 言語の要約は ADR 0001 に置き、ここには測った結果だけを書く。NeNe Delve が 2026-10-23 に公開した Swift 列と、判定（ある／無い／不十分）は 8 項目とも一致した。差分は追加で測った API であり、判定はひっくり返っていない。

| 規則 | Kotlin | Go | Rust | C# | Java | **Swift 6.4.1（本リポジトリの実測）** |
| --- | --- | --- | --- | --- | --- | --- |
| 不正状態を表現不能に・網羅性 | ある | 無い | ある | ある | ある | 不十分。ケース漏れは `switch must be exhaustive` の error。`default` と `case _` は `-warnings-as-errors` でも診断が無く終了 0。`@unknown default` の既知ケース漏れは warning のまま終了 0 |
| 公開状態は不変 | ある | 無い | ある | ある | ほぼある | 不十分。`let` と `private(set)` は代入を拒否。`public var` は可変な束縛から通る。クラスの `public var` は `let` 束縛でも通る |
| `null` の意味は一つ | 不十分 | 不十分 | ある | ある | 不十分 | 不十分。本コンパイルの未初期化 `let` は error。`-typecheck` だけでは終了 0。IUO と強制アンラップと空 struct の `Marker()` は通る |
| 非公開コンストラクタ＋唯一のファクトリ | ある | 不十分 | ある | ある | ある | 不十分。`private init` は他ファイルから不可。明示 init が無い public struct の memberwise は同一モジュールの他ファイルから可で、他モジュールからは internal で不可。`unsafeBitCast` は他モジュールからでも通る |
| 決定性（時刻・乱数・環境を読ませない） | planned | planned | ある | ある | ある | 不十分。Foundation / Glibc / Dispatch はパッケージ依存なしで import できる。`Int.random`、`ContinuousClock`、`SystemRandomNumberGenerator`、`Date()`、`ProcessInfo`、`Locale.current` が通る |
| 依存方向は物理的 | ある | ある | ある | ある | ある | ターゲット間は有る（`no such module` / `cyclic dependency declaration found`）。標準モジュールは漏れる |
| 抑制は例外であって道具ではない | waiver 台帳 | 理由必須 | forbid 層 | 全面禁止 | waiver 台帳 | 不十分。警告抑制の pragma は無い。`swift-format-ignore` と `swiftlint:disable` は理由なしで効く。SwiftLint 0.65.1 に `--baseline` がある |

baseline を言語は塞がない。動的な SwiftLint 0.65.1 は GLIBC_2.38 を要求して起動せず、同梱の `swiftlint-static` は起動した。

---

## 1. 憲章規則

### ARC-001 — 一つの意味に一つの正典経路

一つの意味には、正典となる型・所有者・振る舞いの経路がちょうど 1 つ存在する。通貨が増える経路は回収口に粒が入ったときだけ、解放の経路は反応が初めて起きたときだけ、とする。置き換えは呼び出し側の移行と旧経路の削除を同じ変更で行う。

- 機械強制: **planned**（意味が同じかは機械が判定できない。CNF-001 が総称名を拒否する）

### ARC-002 — 依存方向は物理的である

依存は [PROJECT_LAYOUT.md](PROJECT_LAYOUT.md) と `eng/module-graph.txt` に従う。禁じた依存は import できないことである。循環は許さない。

- 機械強制: **active**（CNF-011 が Package.swift と import をグラフと照合する。SwiftPM は未宣言モジュールを `no such module` で、循環を `cyclic dependency` で拒む）

### ARC-003 — 中核はプラットフォームから独立している

NeNeSandCore、NeNeSandSave、NeNeSandRender は端末・ファイル・ネットワーク・現在時刻・既定ロケールを知らない。NeNeSandTerminal は Glibc の termios / ioctl / signal だけを包む。ファイルの読み書きと時計と乱数源の組み立ては NeNeSandApp だけが行う。

- 機械強制: **planned**（Foundation と Glibc の import 禁止は ARC-002 と ARC-007 が既に見ている。ファイル API の綴りを全部は見ていない）

### ARC-004 — 状態には唯一の所有者がいる

| 状態 | 意味 | 所有者 | 変更経路 |
| --- | --- | --- | --- |
| 盤面 | 粒の配置 | NeNeSandCore | 1 tick と、描く／消す入力の適用 |
| 進行 | 解放済みの物質、通貨、装置、倍率 | NeNeSandCore | 発見、回収、購入、プレステージ |
| セーブ文字列 | 進行の版つき表現 | NeNeSandSave | Core の進行との変換だけ。ファイルは知らない |
| セル格子 | 半角ブロックの描画値 | NeNeSandRender | 盤面からその場で作る |
| 端末属性 | termios、マウス報告、カーソル | NeNeSandTerminal | 起動で設定し、終了で戻す |
| 時計と乱数とファイル | プロセスの外 | NeNeSandApp | 合成ルートだけ |

同じ事実を 2 つのモジュールに独立して持たない。色は Render の配色表だけが持つ。Core は物質の種類と状態だけを持つ。

- 機械強制: **planned**（表の所有者がコードと一致するかは、製品の型がまだ無い）

### ARC-005 — 可変性は隔離区画にのみ存在する

外から見える Core / Save / Render の状態は不変とする。可変な状態を持ってよいのは次だけである。

| 区画 | 何が可変か | なぜ必要か |
| --- | --- | --- |
| NeNeSandTerminal | 端末属性 | 異常終了でも元に戻すため、プロセスが握っている |
| NeNeSandApp | ループの時計、乱数の種、セーブファイルのハンドル | 外部との境界がここだけだから |

区画を増やすには、この表と ADR を先に変える。

- 機械強制: **planned**（CNF-012 は `public var` だけを拒否する。区画の中身はまだコードが無い）

### ARC-006 — 合成は明示的である

依存は NeNeSandApp で与える。サービスロケータ、リフレクションによる発見、暗黙のシングルトン、可変なグローバル登録簿を使わない。端末への出力と終了コードを扱ってよいのは NeNeSandApp だけである。出してよいのは起動できなかった理由 1 行だけである。

- 機械強制: **planned**（実行ターゲットが NeNeSandApp だけであることは CNF-011 が見る。サービスロケータの形は見ていない）

### ARC-007 — 既定で決定的である

中核は、現在時刻・乱数・既定ロケール・既定タイムゾーン・環境変数・プロセス状態を直接読まない。読んでよいのは NeNeSandApp だけである。乱数アルゴリズム自体は種を受け取る純な関数として Core に置いてよい。システム乱数を読んではならない。テストソースができても同じ禁止に従う。

- 機械強制: **active**（CNF-010 が、NeNeSandApp 以外での `Date()`、`ContinuousClock`、`SystemRandomNumberGenerator`、`.random(`、`ProcessInfo`、`Locale.current`、`TimeZone.current`、`Calendar.current`、`FileManager`、`getenv`、`time(`、`clock_gettime`、`gettimeofday`、`arc4random` を拒否する）

### ARC-008 — 境界は一度だけ検証する

セーブと利用者入力は、最初の自前の境界で検証し、その場で Core の型へ変換する。検証前の生の値を Core へ流さない。描画と永続化で違う規則の検証を二重に書かない。

- 機械強制: **planned**（境界が一度かはレビュー事項。SWF-007 が生成経路を狭める）

### ARC-009 — 永続化の契約は版を持つ

保存するのは進行である。形式は版を 1 つ持ち、読めない版は既定値へ黙って落とさず、型のある失敗で返す。読めなかったときは 1 行出して新規で始める。直列化の文字列は NeNeSandSave に閉じ、ファイルの読み書きは NeNeSandApp に閉じる。盤面そのものを保存するかは、製品のセーブを書く ADR で決める。

- 機械強制: **planned**（セーブ形式がまだ無い）

### ARC-010 — 期待される結果は型で表す

検証エラー、読めないセーブ、拒否は閉じた結果型で返す。`throws` はプログラム上の欠陥、キャンセル、下位層の想定外に限る。Optional の `nil` で失敗を表さない。

- 機械強制: **planned**（期待される `throws` と欠陥の `throws` を機械は区別できない）

### ARC-011 — UI は状態を描き、意図を発行する

NeNeSandRender は盤面からセル格子を作るだけである。NeNeSandTerminal はセルを書き、キーとマウスの生イベントを返すだけである。物質の状態遷移、通貨の加減、セーブの呼び出しをこの 2 つに置かない。端末座標から盤面座標への変換は 1 か所にだけ書く。

- 機械強制: **planned**（描画コードがまだ無い）

### ARC-012 — アーキテクチャは利便性に優先する

道具の近道が、状態の所有者やモジュールグラフを迂回することを許さない。間違っているなら ADR で変える。

- 機械強制: **不能**（判断そのものが対象。QLT-010 の手続きで担保する）

---

## 2. 強制を置く順番

1. 言語の型・可視性・網羅性
2. SwiftPM のターゲットグラフ
3. `-warnings-as-errors`
4. 字句による API 禁止
5. swift-format と SwiftLint
6. `eng/conformance.py`
7. CI のマージゲート
8. まだ自動化できない判断だけをレビューへ
