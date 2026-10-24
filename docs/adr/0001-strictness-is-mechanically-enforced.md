# ADR 0001 — 厳格さは機械で強制する

- 状態: 受理
- 日付: 2026-10-24
- Issue: #1
- 影響する規則: ARC-001 から ARC-012、SWF-001 から SWF-015、QLT-001 から QLT-013、CNF-001 から CNF-013、GIT-001 から GIT-004

## 文脈

NeNe Sand の規約は、一つの意味に一つの正典経路を作り、それを人の記憶ではなく機械に守らせる、という原則を Swift へ適用したものである。Swift への適用は NeNe Delve が 1 回目で、このリポジトリが 2 回目である。比較対象は、NeNe Delve（2026-10-23、Swift 6.4.1）の測定として渡された Swift 列である。公開リポジトリのコードは写していない。

規約は、破ったときに何も起きなければ、時間とともに必ず腐る。製品の型を書く前にゲートを入れる。違反ゼロで始められる時点は今だけである。

### Swift 6.4.1 で実測したこと

環境: Swift 6.4.1（swiftly 1.2.0）、対象 `x86_64-unknown-linux-gnu`、glibc 2.35。使い捨てのソースを `swiftc -parse-as-library -typecheck -warnings-as-errors` と `swift build` でコンパイルした。

| 問い | 判定 | 根拠 |
| --- | --- | --- |
| 網羅性 | 不十分 | ケース漏れは `error: switch must be exhaustive`。`default` と `case _` は診断なしで typecheck 終了 0。`@unknown default` は `warning: switch must be exhaustive` のまま、`-warnings-as-errors` でも typecheck 終了 0 |
| 公開状態 | 不十分 | `public let` は `cannot assign to property: 'kind' is a 'let' constant`。`private(set)` は `setter is inaccessible`。`public var` は `var` 束縛から代入でき終了 0。クラスの `public var` は `let` 束縛でも終了 0。返した `Array` への `append` は終了 0 で、本体は変わらない |
| `nil` | 不十分 | 本コンパイルの未初期化 `let` は `error: constant 'value' used before being initialized`。同じソースの `-typecheck` は終了 0。IUO、強制アンラップ、`Optional` の `nil`、空 struct の `Marker()` は typecheck 終了 0 |
| ファクトリ | 不十分 | 同一モジュールの他ファイルからの `private init` は `'Token' initializer is inaccessible due to 'private' protection level`。他モジュールからも同様。明示 init が無い public struct の memberwise は同一モジュールでは `Build complete`、他モジュールでは `inaccessible due to 'internal' protection level`。`unsafeBitCast` は同一モジュールでも他モジュールでも `Build complete` |
| 決定性 | 不十分 | 依存宣言の無いターゲットで `import Foundation`、`import Glibc`、`import Dispatch`、`Int.random`、`ContinuousClock`、`SystemRandomNumberGenerator`、`Date()`、`ProcessInfo.processInfo.environment`、`Locale.current` がすべて `Build complete`。`no_std` に相当するスイッチは無い |
| 依存方向 | 不十分 | 依存していないターゲットの import は `error: no such module 'Shell'`。循環は `cyclic dependency declaration found: Core -> Shell -> Core`。宣言した依存は `Build complete`。標準モジュールは上の行のとおり漏れる |
| 抑制 | 不十分 | 警告抑制の pragma は無い。未使用値の警告は `-warnings-as-errors` で `error:` になり終了 1。`-suppress-warnings` と `-warnings-as-errors` は `conflicting options`。`// swift-format-ignore` は理由なしで `swift-format lint --strict` を終了 0 にした。`// swiftlint:disable all` は強制アンラップを黙らせた |
| baseline | 言語では塞がらない | SwiftLint 0.65.1 に `--baseline` と `--write-baseline` がある。動的バイナリは `GLIBC_2.38 not found` で起動しない。同梱の `swiftlint-static` は版 0.65.1 で起動した |

NeNe Delve の Swift 列との突き合わせ: 8 項目とも判定は一致した。こちらが追加で通ることを見たのは `SystemRandomNumberGenerator`、`Date()`、`ProcessInfo`、`Locale.current`、他モジュールからの `unsafeBitCast`、memberwise が他モジュールでは internal で止まること、である。どれも「不十分」を「ある」には変えない。

テストが 1 本も無いパッケージで `swift test` は `error: no tests found`、終了 1 だった。Swift Testing 6.4.1 の `@Test` は 1 件成功した。

循環的複雑度 12 は SwiftLint `cyclomatic_complexity` が error にした。引数 5 個は `function_parameter_count`、46 行は `function_body_length`、関数ネスト 4 段は `nesting` が error にした。4 段の `if` は `nesting` では落ちなかった。

**そして、いま製品の振る舞いは空である。** 錨の enum と合成ルートの `main` だけがある。baseline は要らない。

## 決定

すべての規範規則に機械強制の状態を持たせ、その状態を文書の側で機械検査する。

1. 規則の正本を `docs/ARCHITECTURE_CONSTITUTION.md`、`docs/CODING_RULES.md`、`docs/QUALITY_GATES.md` に置く。状態は active / planned / 不能 / 不採用 で、planned を active と書かない
2. `make check` を唯一の入口にする。CI は同じコマンドを呼ぶだけにする
3. baseline を持たない。例外は期限付きの狭い waiver だけである
4. 抑制には直前行の waiver ID を要求する。Swift は抑制を言語で封じられないので、台帳を持つ
5. ゲートを弱める変更は ADR を要する
6. Swift の版は `.swift-version` だけ、SwiftLint の版と zip の sha256 は `eng/tool-versions.txt` だけが決める。swiftly が読むファイルと SwiftLint の pin は別ファイルにする。同じ値を Makefile とワークフローに書かない
7. ゲートは意図的な違反で発火することを証明してから active と書く
8. 規約検査 `eng/conformance.py` は Python 標準ライブラリだけで書く

製品テストの枠組みは ADR 0002 で Swift Testing に決めた。振る舞いが無いので `swift test` は結線しない。

## 強制

- active: 強制マトリクスに active と書いた行。証明は `docs/quality/gate-proofs.md`
- planned: 意味の同一性、セーブ形式、期待される失敗と欠陥の区別、カバレッジ、ruleset の strict
- 不能: ARC-012 と QLT-010。判断そのものだから

## 結果

得られるもの:

- 規約が自分について嘘をつく経路が狭まる
- 何がいま守られているかを 1 か所で読める
- 規約を緩めるコストが上がる

失うもの:

- 規則を足すたびに本文、マトリクス、実装を同じ変更で動かすコスト
- 列挙していない API は、決定性の検査を通ってしまう

正直に記録しておくこと:

- `default`、`case _`、`@unknown default`、IUO、強制アンラップ、`public var`、`unsafeBitCast`、標準モジュールの import は、言語が塞がない
- `-typecheck` は未初期化の `let` を見ない。ゲートは本コンパイルを使う
- 緑であることは、規則が良いことの証明ではない。検査対象がまだ小さいことの結果でもある。実装で規則が邪魔になったとき、緩めるのではなく ADR で判断を残す

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| 散文の規約だけを置く | 守られているかを確かめる手段が無く、時間とともに必ず腐る |
| 既製 lint の既定セットだけで済ませる | 「Swift として危ういこと」は見ても、「NeNe Sand として守るべきこと」は見ない |
| 全 lint の一括有効化 | 矛盾する lint が同時に入り、規則ではなく道具の機嫌に従う |
| baseline を作って既存違反を後回しにする | 製品の振る舞いがまだ無く、既存違反が無い。ここで許すと以後の違反も同じ入口から入る |
| 実装が入ってから導入する | 既存違反を凍結する baseline が必要になる |
| 規約を `CLAUDE.md` にだけ書く | 人間と AI の遵守に依存する |
| 規則 ID を付けず散文で参照する | どの規則の話かがレビューのたびに揺れる |
| Delve の実装を写す | 2 回目の実測で比較表を確かめるのが、この Issue の目的の一つである |
| 動的リンクの SwiftLint | GLIBC_2.38 が無く起動しなかった |
| `swift test` を空のままゲートに入れる | テスト 0 件で終了 1 になる。意味の無いテストで結線しない |

## 関連

- 先行言語の測定: Kotlin、Go、Rust、C#、Java。Swift の直前の測定は NeNe Delve
- 製品テストの枠組み: ADR 0002
