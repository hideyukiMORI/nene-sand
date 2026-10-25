# 品質ゲート — NeNe Sand

> Status: normative（規範）/ 2026-10-24 初版
> 本書は「いま何が機械で守られているか」の正本である。

`make check` がローカルと CI の唯一の完了定義である。個別の道具は診断のために単独で回してよいが、その成功は完了の代わりにならない。

---

## 1. ゲートの整合性規則

### QLT-001 — ゲートは一つ

ローカルと CI は `make check` だけを完了定義にする。CI のワークフローに品質判断のロジックを書かない。Swift の版は `.swift-version` だけ、SwiftLint の版は `eng/tool-versions.txt` だけに書く。

- 機械強制: **active**（CNF-007。ワークフローが `make check` 以外の品質コマンドを持つと QLT-005 も同じ行に出る）

### QLT-002 — 警告は失敗する

コンパイラの警告は `Package.swift` の `-warnings-as-errors` でエラーになる。整形差分と SwiftLint の指摘も失敗にする。重大度の引き下げは禁止。

- 機械強制: **active**（`eng/run_build.py` が `[#` 付きの失敗に QLT-002 を付ける。swift-format は QLT-004、SwiftLint は SWF-004 と SWF-012）

### QLT-003 — baseline を作らない

lint、静的解析、依存、テストの baseline を持たない。既存の違反を無かったことにする経路を作らない。唯一の例外は期限付きの狭い waiver である。

- 機械強制: **active**（CNF-005）

### QLT-004 — 整形は検査であって修復ではない

整形の正本は `.swift-format` の 1 ファイルで、中身は Swift 6.4.1 の `swift-format dump-configuration` である。CI はソースを書き換えない。

- 機械強制: **active**（`eng/run_format.py` が `swift-format lint --strict` を呼ぶ）

### QLT-005 — ローカルと CI は同一

CI で必要なゲートは、すべてローカルの `make check` で実行できる。検査を足すときは、まず Makefile に足す。

- 機械強制: **active**（ワークフローの `run` が品質コマンドを直接持つと、QLT-001 の行に QLT-005 も出る）

### QLT-006 — アーキテクチャは実行可能

モジュール境界は `eng/module-graph.txt` が正本で、CNF-011 がビルドグラフと import を照合する。散文だけの境界は、不能と明記されない限り未完成として扱う。

- 機械強制: **active**（CNF-011）

### QLT-007 — カスタムゲートには negative proof が要る

自作の検査は、わざと違反させた入力で意図した規則 ID によって落ちることと、戻すと通ることを示すまで信用しない。証拠は [quality/gate-proofs.md](quality/gate-proofs.md) に記録する。検査器の単体テストは `make check` から呼ぶ。

- 機械強制: **active**（`eng/run_tests.py` が失敗すると QLT-007 を出す。CNF-006 は active の規則に証明行が無いと落ちる）

### QLT-008 — 振る舞いの変更はテストを伴う

振る舞いを変えたら、いちばん狭い安定した境界に Swift Testing のテストを足す。砂の落下、水の流れ、砂が水に沈むこと、油が水に浮くこと、火が上って消えること、木が落ちないこと、火と溶岩が油と木に燃え移ること、溶岩が 2 tick に 1 回動くこと、水が溶岩を石にすること、石が落ちて溜まること、線、半角ブロック、マウス列、右クリックの消去、全消去、一時停止、筆の正方形、自由に遊ぶの印、英語の 6 行計器、緑と琥珀のテーマ、数字キーはテストがある。`make check` は `swift test` を呼ぶ。テストが無い変更を機械は見分けないので、この規則は planned のままである。

- 機械強制: **planned**（レビュー事項。カバレッジ下限は置いていない）

### QLT-009 — カバレッジは下げられない

中核の分岐カバレッジ下限は置いていない。製品の分岐が存在してから、測った値で下限を置き、下げるには ADR を要する。

- 機械強制: **planned**（置いていない）

### QLT-010 — ゲートの弱体化はアーキテクチャ変更

重大度、除外、閾値、モジュール境界、必須 CI を弱めるには ADR か waiver が要る。無関係な作業を通すために検査を切ることは禁止。

- 機械強制: **不能**（判断そのものが対象。PR の手続きで担保する）

### QLT-011 — 依存は再現可能

実行時の依存は 0 である。`Package.swift` に `.package` を書くとゲートが落ちる。最初の依存を足すときは、ADR と許可リストと lock を同じ変更で足す。lock がまだ無いのは、固定する依存が無いからである。

- 機械強制: **active**（CNF が `.package(` を見ると QLT-011 を出す）

### QLT-012 — 検証の頻度は変更に従う

反復中は最も狭い検査を使う。フルゲートは PR を Draft から Ready にする直前に通す。CI は draft の間は走らない。head が動いたら Draft に戻して再度 Ready にする。

- 機械強制: **planned**（ワークフローの `draft == false` は検査が見ている。ruleset の strict up-to-date はリポジトリ設定であり、`make check` はそれを読んでいない。設定した事実は gate-proofs に書き、設定前に active と呼ばない）

### QLT-013 — 環境依存の主張は正直に名付ける

単体テストは表示サーバも Windows Terminal も必要としない。単体テストが通ったことを、端末で砂が動く証拠として扱わない。

- 機械強制: **planned**（表示を伴う確認は、製品が動いてから別に記録する）

---

## 2. 規約検査の規則 — `eng/conformance.py`

依存は Python 標準ライブラリだけである。製品のテストソースはまだ無く、`eng/test_*.py` は検査対象から外す。検出語は検査器のソースに直書きしない。

### CNF-001 — 禁止された総称名

型名の語尾 `Manager` / `Helper` / `Util` / `Utils` / `Common` と、禁止ディレクトリ名を拒否する。

- 機械強制: **active**（SWF-010）

### CNF-002 — 1 ファイル 1 主要宣言

トップレベルの型は 1 つで、ファイル名と一致する。

- 機械強制: **active**（SWF-011）

### CNF-003 — 抑制には waiver の直前行が要る

行単位の抑制だけを許し、ファイル範囲の抑制は拒否する。

- 機械強制: **active**（SWF-015）

### CNF-004 — waiver 台帳の整合

`WVR-NNNN-kebab.md` の Rule、Expires、Scope、索引、期限を見る。期限切れは落とす。

- 機械強制: **active**（SWF-015）

### CNF-005 — baseline とゲート無力化の禁止

ファイル名の baseline、`--baseline`、`-suppress-warnings`、`ignoreFailures`、`new-from-rev`、SwiftLint の `excluded` と `disabled_rules` を拒否する。

- 機械強制: **active**（QLT-003）

### CNF-006 — 文書整合

規則 ID の重複定義、未定義の参照、マトリクスに無い規則、本文の機械強制とマトリクスの不一致、active なのに証明行が無いことを拒否する。証明行は `docs/quality/gate-proofs.md` で、行頭が `| 規則ID |` のものだけを読む。

- 機械強制: **active**

### CNF-007 — 宣言した設定がビルドから読まれている

`.swift-version`、`.swift-format`、`.swiftlint.yml`、`eng/tool-versions.txt`、`eng/module-graph.txt`、`eng/conformance.py` が Makefile かランナーかワークフローに現れることを見る。版の値を Makefile とワークフローに重複して書かない。`Package.swift` の tools-version は `.swift-version` の major.minor と一致する。

- 機械強制: **active**

### CNF-008 — 未完了の印には Issue 番号

Swift、Python、YAML、シェル、Makefile の未完了の印は、同じ行に `#` と Issue 番号が要る。

- 機械強制: **active**

### CNF-009 — 網羅性を消す分岐

`default:`、`case _`、`@unknown default` を拒否する。

- 機械強制: **active**（SWF-002）

### CNF-010 — 決定性の綴り

NeNeSandApp 以外の時刻・乱数・環境の綴りと、Sources 全体の Task / Dispatch を拒否する。

- 機械強制: **active**（ARC-007 と SWF-013）

### CNF-011 — モジュールグラフ

`eng/module-graph.txt` と `Package.swift` の依存、実行ターゲットが NeNeSandApp だけであること、ファイルの import がグラフの許可と一致することを見る。

- 機械強制: **active**（ARC-002 と QLT-006）

### CNF-012 — 公開の var

`public var` と `open var` を拒否する。`public private(set) var` は拒否しない。

- 機械強制: **active**（SWF-003）

### CNF-013 — ビット列の迂回

`unsafeBitCast` と `unsafeDowncast` を拒否する。

- 機械強制: **active**

---

## 3. 強制マトリクス

| 規則 | 状態 | 機械強制の実体 |
| --- | --- | --- |
| ARC-001 | planned | レビュー。CNF-001 が温床を減らす |
| ARC-002 | active | CNF-011 と SwiftPM |
| ARC-003 | planned | import 禁止は ARC-002 と ARC-007 が部分的に見る |
| ARC-004 | planned | 所有者の表。機械は表とコードの一致を見ない |
| ARC-005 | planned | 区画の表。CNF-012 は public var だけ |
| ARC-006 | planned | 実行ターゲットが 1 つであることは CNF-011 |
| ARC-007 | active | CNF-010 |
| ARC-008 | planned | レビュー |
| ARC-009 | planned | セーブ形式はまだ無い |
| ARC-010 | planned | レビュー |
| ARC-011 | planned | Render と Terminal の分離はレビュー |
| ARC-012 | 不能 | QLT-010 の手続き |
| SWF-001 | planned | レビュー |
| SWF-002 | active | コンパイラと CNF-009 |
| SWF-003 | active | CNF-012 |
| SWF-004 | active | 本コンパイルと SwiftLint |
| SWF-005 | planned | レビュー |
| SWF-006 | planned | レビュー |
| SWF-007 | planned | CNF-013 は迂回の 2 綴りだけ |
| SWF-008 | planned | レビュー |
| SWF-009 | planned | CNF-013 が部分 |
| SWF-010 | active | CNF-001 |
| SWF-011 | active | CNF-002 |
| SWF-012 | active | SwiftLint の名指し 5 規則 |
| SWF-013 | active | CNF-010 |
| SWF-014 | planned | Locale.current は ARC-007 |
| SWF-015 | active | CNF-003 と CNF-004 |
| GIT-001 | planned | PR テンプレート。本文の妥当性は不能な側面 |
| GIT-002 | active | `eng/commit_message.py` |
| GIT-003 | active | `eng/commit_message.py` と `.githooks/commit-msg`。CI は同じ検査に PR タイトルを渡す |
| GIT-004 | planned | ruleset の squash は gate-proofs に記録する。make check は GitHub を読まない |
| QLT-001 | active | CNF-007 とワークフロー検査 |
| QLT-002 | active | Package.swift の警告のエラー化 |
| QLT-003 | active | CNF-005 |
| QLT-004 | active | swift-format lint --strict |
| QLT-005 | active | ワークフローが品質コマンドを直接持たないこと |
| QLT-006 | active | CNF-011 |
| QLT-007 | active | unittest と証明行の存在 |
| QLT-008 | planned | レビュー。ADR 0002 |
| QLT-009 | planned | 置いていない |
| QLT-010 | 不能 | PR の手続き |
| QLT-011 | active | Package.swift に外部パッケージを書かない |
| QLT-012 | planned | draft 条件は見ている。ruleset は未接続 |
| QLT-013 | planned | 実機確認はまだ無い |
| CNF-001 | active | eng/conformance.py |
| CNF-002 | active | eng/conformance.py |
| CNF-003 | active | eng/conformance.py |
| CNF-004 | active | eng/conformance.py |
| CNF-005 | active | eng/conformance.py |
| CNF-006 | active | eng/conformance.py |
| CNF-007 | active | eng/conformance.py |
| CNF-008 | active | eng/conformance.py |
| CNF-009 | active | eng/conformance.py |
| CNF-010 | active | eng/conformance.py |
| CNF-011 | active | eng/conformance.py |
| CNF-012 | active | eng/conformance.py |
| CNF-013 | active | eng/conformance.py |

---

## 4. `make check` に入っている層

| 層 | 目的 | 実体 |
| --- | --- | --- |
| コンパイル | 型、網羅性、警告ゼロ | `swift build`（`-warnings-as-errors`） |
| 整形 | 文字列としての正本 | `swift-format lint --strict` |
| API 禁止 | 時刻、乱数、Task、Dispatch | CNF-010 |
| 静的解析 | 複雑度、強制アンラップ、IUO | SwiftLint 0.65.1 static |
| アーキテクチャ | ターゲットと import | CNF-011 |
| 規約検査 | このリポジトリ固有 | `eng/conformance.py` |
| 検査自身のテスト | 正例と反例 | `eng/test_conformance.py` と `eng/test_commit_message.py` |
| 製品の単体テスト | 砂の落下、水の流れ、油が水に浮くこと、火が上って消えること、木が落ちないこと、火と溶岩が油と木に燃え移ること、溶岩が 2 tick に 1 回動くこと、水が溶岩を石にすること、石が落ちて溜まること、線、半角ブロック、マウス列、右クリックの消去、全消去、一時停止、筆の正方形、自由に遊ぶの印、英語の 6 行計器、緑と琥珀のテーマ、数字キー | `swift test`。失敗すると QLT-008。カバレッジ下限は置いていない |
| カバレッジ | 中核の検証密度 | 置いていない |
| 依存 | 再現性 | 実行時依存 0。SwiftLint の zip は sha256 で照合する |

---

## 5. マージゲート

`main` へ求めるものは次である。ruleset を適用する前に、適用済みとは書かない。

- Pull Request 経由であること
- `make check` が成功していること（CI のジョブ名 `check`）
- squash merge だけ
- `main` への直接 push、force push、ブランチ削除を拒否すること

適用したかどうかの読み戻しは [quality/gate-proofs.md](quality/gate-proofs.md) に書く。
