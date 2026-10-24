# ゲート発火の証明 — NeNe Sand

> Status: 記録 / 最終実測 2026-10-24
> 根拠となる規則: QLT-007

検査は落ちることを見るまで信用しない。各仕込みは戻してから次を入れた。全部戻したあと、規約検査、単体テスト、コミット検査、整形、SwiftLint が終了 0 になり、続けて `make check` も終了 0 だった。

環境: Linux x86_64、glibc 2.35、Swift 6.4.1、swift-format 6.4.1、SwiftLint 0.65.1 static
CI: ubuntu-22.04。ジョブ名 `check`。Ready 後の run 40105035976 は廃止された swiftly-install.sh が 404（curl 終了 22）で失敗した。導入は `eng/tool-versions.txt` の swiftly 1.2.0 tarball に替えた。続く run 40105215588 は swiftly と toolchain を通過し、`make check` が `GIT-003` で終了 1 になった。原因は `pull_request` の既定 checkout が合成 merge commit で、その件名が規約の形ではないこと。checkout は PR head の SHA に固定し、比較基点は `BASE_SHA` にする。その実行の成否は、終わってから書く

---

## 1. 実測結果

### 1-a. active の規則

| 規則 | 最小の違反 | 検証経路 | 実測 |
| --- | --- | --- | --- |
| ARC-002 | Core が Terminal を import する | `python3 eng/conformance.py eng/module-graph.txt` | 終了 1。`NeNeSandCore は NeNeSandTerminal を import できない (ARC-002) (QLT-006)` |
| ARC-007 | Core に `Date()` | 同上 | 終了 1。`時刻・乱数・環境の綴りを NeNeSandCore に書いた (ARC-007)` |
| CNF-001 | 型 `TimeHelper` | 同上 | 終了 1。`禁止語尾 Helper (SWF-010)` |
| CNF-002 | 1 ファイルに enum を 2 つ | 同上 | 終了 1。`主要宣言は 1 つ（実際は 2）(SWF-011)` |
| CNF-003 | waiver 無しの `swiftlint:disable:next` | 同上 | 終了 1。`抑制の直前行に Waiver ID が無い (SWF-015)` |
| CNF-004 | Expires が 2020-01-01 の waiver | 同上 | 終了 1。`期限切れの waiver (SWF-015)` |
| CNF-005 | Makefile に baseline フラグ | 同上 | 終了 1。`ゲートを無力化する綴り` として baseline フラグを報告 (QLT-003) |
| CNF-006 | README に未定義の規則 ID | 同上 | 終了 1。`未定義の規則 ID を参照している` |
| CNF-007 | Makefile に Swift の版の値を重複 | 同上 | 終了 1。`.swift-version: Swift の版の値を Makefile かワークフローに重複して書いた` |
| CNF-008 | Issue 番号の無い未完了の印 | 同上 | 終了 1。`未完了の印には Issue 番号が要る` |
| CNF-009 | `switch` の `default` | 同上 | 終了 1。`網羅性を消す (SWF-002)` |
| CNF-010 | Core の `Date()` と、App の `import Dispatch` | 同上 | 終了 1。前者は ARC-007、後者は SWF-013 |
| CNF-011 | Core が Terminal を import する | 同上 | 終了 1。ARC-002 と QLT-006 を含む |
| CNF-012 | `public static var` | 同上 | 終了 1。`public / open var (SWF-003)` |
| CNF-013 | `unsafeBitCast` | 同上 | 終了 1。`非公開初期化子を迂回する` |
| GIT-002 | ブランチ名 `feature-branch` | `PR_HEAD` を渡して `python3 eng/commit_message.py --check` | 終了 1。`GIT-002: ブランチ名 feature-branch は type/番号-kebab にする` |
| GIT-003 | 件名 `build: nope` | `PR_TITLE` を渡して同じ検査 | 終了 1。`GIT-003: 件名は type(scope): 日本語 (#N) の形にする` |
| QLT-001 | ワークフローに `swiftlint` の run を足す | 規約検査 | 終了 1。`品質判断 swiftlint をワークフローに書いた (QLT-005)` |
| QLT-002 | 未使用の `let forgotten` | `python3 eng/run_build.py` | 終了 1。`error: ... [#NoUsage]` のあと `QLT-002: 警告をエラーとしてコンパイルを止めた` |
| QLT-003 | Makefile の baseline フラグ | 規約検査 | 終了 1。CNF-005 の行に QLT-003 が含まれる |
| QLT-004 | `main( )` の余分な空白 | `python3 eng/run_format.py` | 終了 1。`[Spacing] remove 1 space` と `QLT-004` |
| QLT-005 | ワークフローに品質コマンドを直接書く | 規約検査 | 終了 1。QLT-001 の行に QLT-005 が含まれる |
| QLT-006 | 禁じた向きの import | 規約検査 | 終了 1。CNF-011 の行に QLT-006 が含まれる |
| QLT-007 | 通るはずのアサーションを壊す | `python3 eng/run_tests.py` | 終了 1。`AssertionError` のあと `QLT-007: 規約検査の単体テストが失敗した` |
| QLT-011 | `Package.swift` に `.package(` | 規約検査 | 終了 1。`外部パッケージ依存は ADR と許可リストが揃うまで足さない` |
| SWF-002 | `default` | 規約検査 | 終了 1。CNF-009 の行に SWF-002 が含まれる |
| SWF-003 | `public static var` | 規約検査 | 終了 1。CNF-012 の行に SWF-003 が含まれる |
| SWF-004 | `value!` | `python3 eng/run_lint.py` | 終了 2。`(force_unwrapping)` と `SWF-004` |
| SWF-010 | 型 `TimeHelper` | 規約検査 | 終了 1。CNF-001 の行に SWF-010 が含まれる |
| SWF-011 | 1 ファイルに型を 2 つ | 規約検査 | 終了 1。CNF-002 の行に SWF-011 が含まれる |
| SWF-012 | 引数 5 個の関数 | `python3 eng/run_lint.py` | 終了 2。`(function_parameter_count)` と `SWF-012` |
| SWF-013 | `import Dispatch` | 規約検査 | 終了 1。`Dispatch を import できない (SWF-013)` |
| SWF-015 | waiver 無しの抑制、期限切れ waiver | 規約検査 | 終了 1。CNF-003 と CNF-004 の行に SWF-015 が含まれる |

### 1-b. 候補に対する結果

| # | 規則 | 仕込む違反 | 実行するタスク | 結果 |
| --- | --- | --- | --- | --- |
| P1 | ARC-007 | 中核で `Date()` | 規約検査 | 終了 1。戻すと終了 0 |
| P2 | ARC-002 | 禁じた import | 規約検査 | 終了 1。戻すと終了 0 |
| P3 | SWF-002 | `default` | 規約検査 | 終了 1。戻すと終了 0 |
| P4 | QLT-002 | 未使用の `let` | `eng/run_build.py` | 終了 1。戻すと `swift build` は終了 0 |
| P5 | CNF-001 | `TimeHelper` | 規約検査 | 終了 1。戻すと終了 0 |
| P6 | CNF-003 | waiver 無しの抑制 | 規約検査 | 終了 1。戻すと終了 0 |
| P7 | CNF-004 | 期限 2020-01-01 | 規約検査 | 終了 1。戻すと終了 0 |
| P8 | QLT-004 | `main( )` | `eng/run_format.py` | 終了 1。戻すと終了 0 |
| P9 | CNF-005 | baseline フラグ | 規約検査 | 終了 1。戻すと終了 0 |
| P10 | CNF-006 | 未定義 ID | 規約検査 | 終了 1。戻すと終了 0 |
| P11 | CNF-007 | 版の値の重複 | 規約検査 | 終了 1。戻すと終了 0 |
| P12 | GIT-003 | `build: nope` | `eng/commit_message.py --check` | 終了 1。環境変数を外すと終了 0 |

除外側の確認:

| 区画 | 適用しない禁止 | 呼んでいる禁止 API | 結果 |
| --- | --- | --- | --- |
| NeNeSandApp | 決定性 | `import Foundation` と `Date()` | 規約検査 終了 0、`swift build` 終了 0。確認後に両方を削除した |

---

## 2. 出力の抜粋

```text
CNF-001: Sources/NeNeSandCore/TimeHelper.swift: 型名 TimeHelper は禁止語尾 Helper で終わる (SWF-010)
CNF-009: ... switch の default / case _ / @unknown default は網羅性を消す (SWF-002)
CNF-010: ... 時刻・乱数・環境の綴りを NeNeSandCore に書いた (ARC-007)
CNF-011: ... NeNeSandCore は NeNeSandTerminal を import できない (ARC-002) (QLT-006)
QLT-002: 警告をエラーとしてコンパイルを止めた
QLT-004: swift-format の検査が失敗した
SWF-004: SwiftLint が対応する違反を報告した
SWF-012: SwiftLint が対応する違反を報告した
QLT-007: 規約検査の単体テストが失敗した
GIT-002: ブランチ名 feature-branch は type/番号-kebab にする
GIT-003: 件名は type(scope): 日本語 (#N) の形にする
```

未使用値のコンパイラ出力は `error: initialization of immutable value 'forgotten' was never used [#NoUsage]` で、警告のまま終了 0 にはならなかった。

---

## 3. 事故から生まれた検査

まだ無い。Phase 0 で、検査器のバイトコードが連結済みの禁止綴りを含み、自分を違反として報告した。`__pycache__` を走査対象から外し、検出語はソースに直書きしない。

---

## 4. リポジトリ設定（ruleset）

2026-10-24 に `gh api repos/hideyukiMORI/nene-sand/rulesets/25785471` で読み戻した。

| 設定 | 値 | 確認日 |
| --- | --- | --- |
| PR 必須 | 有効（`pull_request`。承認数 0。コードオーナー審査なし） | 2026-10-24 |
| 必須 check | `check`（ジョブ名。`CI / check` ではない） | 2026-10-24 |
| strict up-to-date | `strict_required_status_checks_policy: true` | 2026-10-24 |
| force push / ブランチ削除の禁止 | `non_fast_forward` と `deletion` | 2026-10-24 |
| squash のみ | `allowed_merge_methods: ["squash"]` | 2026-10-24 |

対象は `refs/heads/main`。enforcement は `active`。ruleset の id は 25785471。この設定は `make check` の外なので、QLT-012 と GIT-004 は planned のままである。

---

## 5. 環境依存の確認

まだ無い。この Issue の検査は端末を使わない。
