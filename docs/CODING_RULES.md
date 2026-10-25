# Swift 6.4.1 コーディング規約 — NeNe Sand

> Status: normative（規範）/ 2026-10-24 初版
> 判断の根拠は [ADR 0001](adr/0001-strictness-is-mechanically-enforced.md)。
> 本書は Swift を本リポジトリで承認された部分集合に狭める。沈黙している領域は Swift の標準に従う。

読み方と強制の層は [ARCHITECTURE_CONSTITUTION.md](ARCHITECTURE_CONSTITUTION.md) 第 0 節と同じ。

---

## 1. 型と状態

### SWF-001 — 境界でのプリミティブ執着を禁じる

識別子、盤面座標、通貨、版番号のように単位や不変条件を持つ値は専用の型にする。検証は生成時に行う。

- 機械強制: **planned**（専用型にすべき値かどうかはレビュー事項。SWF-007 が型を作ったあとの生成経路を狭める）

### SWF-002 — 閉じた選択肢は閉じた型で表し、網羅性検査を殺さない

物質と反応と結果は enum で表す。分岐に `default`、`case _`、`@unknown default` を書かない。ケースを 1 つ足して分岐を直さなければ、コンパイラが `switch must be exhaustive` で止める。`default` と `case _` はコンパイラが黙って受け入れるので、字句で拒否する。

- 機械強制: **active**（コンパイラがケース漏れを error にし、CNF-009 が `default` / `case _` / `@unknown default` を拒否する）

### SWF-003 — 公開状態は不変

`public var` と `open var` を書かない。`public let` と `public private(set)` は実測で代入を拒否した。Array は値型なので、返したコピーへの `append` は本体を変えない。クラスの `public var` は `let` 束縛でも書き換わるので、公開の `var` 自体を拒否する。

- 機械強制: **active**（CNF-012）

### SWF-004 — `nil` の意味は一つ

`nil` が意味してよいのは「省略可能な値が無い」だけである。未初期化の `let` は本コンパイルが error にする。`-typecheck` だけでは出ないことを実測した。強制アンラップと IUO はコンパイラが通すので、SwiftLint が拒否する。

- 機械強制: **active**（本コンパイルの `-warnings-as-errors` と、SwiftLint の `force_unwrapping` と `implicitly_unwrapped_optional`）

### SWF-005 — 期待される失敗は例外で表さない

検証エラー、見つからない、読めないセーブは閉じた結果型で返す。広い `catch` で握り潰さない。欠陥とキャンセル以外に `throws` を使わない。

- 機械強制: **planned**（期待される失敗と欠陥を機械は区別できない）

### SWF-006 — 汎用データバッグを禁じる

`Any`、`[String: Any]`、意味を持つだけのタプルで型を代用しない。

- 機械強制: **planned**（`Any` の正当な使い方と禁止を字句だけでは分けきれない）

### SWF-007 — 構築が不変条件を守る

不変条件を持つ型の初期化子は非公開にし、生成経路を 1 つのファクトリに集める。ファクトリは想定内の不正入力に例外を投げず、結果型を返す。`private init` は他ファイルから呼べない。明示的な init が無い public struct の memberwise は同一モジュールの他ファイルから呼べる。この穴は、init を自分で書き `private` にすることで塞ぐ。`unsafeBitCast` は CNF-013 が拒否する。

- 機械強制: **planned**（唯一のファクトリであることはレビュー事項。CNF-013 は迂回の 2 綴りだけを拒否する）

---

## 2. 構築と可視性

### SWF-008 — 可視性は最小

既定は非公開。他モジュールが実際に使うものだけ `public` にする。テストのためだけに公開しない。

- 機械強制: **planned**（必要十分な公開かはレビュー事項）

### SWF-009 — 言語マジックを制限する

リフレクション、動的探索、`unsafeBitCast`、`unsafeDowncast`、ビルド時コード生成を禁じる。使うなら ADR が要る。

- 機械強制: **planned**（CNF-013 が `unsafeBitCast` と `unsafeDowncast` だけを拒否する。リフレクションの綴りはまだ見ていない）

### SWF-010 — 名前が役割を語る

型名の語尾に `Manager`、`Helper`、`Util`、`Utils`、`Common` を使わない。ディレクトリ名に `utils`、`helpers`、`managers`、`misc`、`common` を使わない。

承認された役割の語尾は `Port`、`Adapter`、`Query`、`Command`、`Handler`、`Policy`、`Factory`、`Codec`、`Mapper`、`Renderer`、`Reducer`、`Outcome` である。その型がその役割そのものであるときだけ使う。

`Processor` や `Data` のように文脈次第で妥当な語は機械では拒否しない。

- 機械強制: **active**（CNF-001）

### SWF-011 — 1 ファイル 1 主要宣言

ファイルは 1 つの主要な型に閉じる。ファイル名は型名と一致させる。`extension` は主要宣言に数えない。

- 機械強制: **active**（CNF-002）

### SWF-012 — 複雑度に上限を置く

| 指標 | 上限 | 道具 |
| --- | --- | --- |
| 循環的複雑度 | 10 | SwiftLint `cyclomatic_complexity` |
| 関数の長さ | 40 行 | SwiftLint `function_body_length` |
| 関数のネスト | 3 | SwiftLint `nesting` の `function_level` |
| 型のネスト | 3 | SwiftLint `nesting` の `type_level` |
| 引数の数 | 4 | SwiftLint `function_parameter_count` |

`if` の入れ子段数そのものは、この版の `nesting` では測れなかった（4 段の `if` は違反にならず、関数の入れ子は 4 段目で違反になった）。文のネスト段数だけの検査は不能である。分岐の増え方は循環的複雑度 10 が見る。

閾値を満たすためだけに意味のある処理を割らない。超えるときは測定可能な理由を添えて ADR にする。

- 機械強制: **active**（上の 5 つの SwiftLint 規則。`--strict`）

### SWF-013 — 並行性の形は一つ

シミュレーションの tick を進めるのは、合成ルートの同期ループだけである。`Task`、`Task.detached`、`TaskGroup`、`import Dispatch` を Sources のどこにも書かない。Swift 6 言語モードの厳密な並行性はツールチェーンの既定である。データ競合の実測は行っていない。

- 機械強制: **active**（CNF-010 が Task と Dispatch を拒否する）

### SWF-014 — 日時・数値・文字集合の扱いを一つに固定する

日時が必要になったら、合成ルートが読んだ瞬間を値として渡す。ロケール依存の API を既定ロケールで呼ばない。セーブの文字集合は UTF-8 に固定する。

- 機械強制: **planned**（`Locale.current` は ARC-007 が拒否する。文字集合の選択そのものはまだ見ていない）

### SWF-015 — 抑制は例外であって道具ではない

`swiftlint:disable:next`、`swiftlint:disable:this`、`swiftlint:disable:previous`、`swift-format-ignore` は、直前行が `// Waiver: WVR-NNNN` であり、その waiver が期限内であるときだけ書ける。ファイルの残りに効く `swiftlint:disable` と `swiftlint:disable all` は、waiver があっても禁止する。コンパイラには警告抑制の pragma が無い。`-suppress-warnings` は `-warnings-as-errors` と同時に指定すると拒否されることを実測した。単独で使うと警告を隠せるので、ビルド定義に書くことを CNF-005 が拒否する。

- 機械強制: **active**（CNF-003 と CNF-004。台帳は `docs/waivers/`）

---

## 4. 端末の規約

端末に出す文言、マウス座標の変換、終了時の復元は、製品の描画を書くときに 1 か所へ集める。いまはコードが無いので、本節に規則 ID は振らない。振っていないものを active と呼ばない。

---

## 5. 依存の方針

新しい依存を足すときは、次の 3 つを揃える。1 つでも欠けたら足していない。

1. ADR を 1 本立てる
2. 下の表に 1 行足す
3. `Package.swift` の `.package` は、上の 2 つが同じ変更に含まれるまで CNF が拒否する（QLT-011）

| 依存 | 用途 | 根拠 |
| --- | --- | --- |
| — | — | 現在の実行時依存は 0。開発道具の SwiftLint は製品の依存ではない |

許可リストの正本はこの表である。版を範囲や `*` で書かない。

---

## 6. 採用しなかった検査と、その理由

| 検査 | 不採用の理由 |
| --- | --- |
| SwiftLint の一括有効化 | 矛盾する規則が同時に入り、規則ではなく道具の機嫌に従う |
| SwiftLint `identifier_name` の最短 3 文字 | 盤面座標は `x` と `y` である。最短文字数は正典の名前を別名に追い出す |
| swift-format の `NeverForceUnwrap` | 強制アンラップは SwiftLint の `force_unwrapping` が SWF-004 として見る。同じ規則を 2 か所に置かない |
| `if` のネスト段数を単独で拒む lint | SwiftLint 0.65.1 の `nesting` は関数と型のネストであり、4 段の `if` では発火しなかった |
| XCTest と Swift Testing の併用 | テスト枠組みは 1 つ（ADR 0002） |
| 動的リンクの SwiftLint | 0.65.1 の動的バイナリは GLIBC_2.38 が無く起動しなかった。静的バイナリだけを使う |
| ncurses と、その他の製品依存 | 実行時依存は 0 から始める。足すなら本節の 3 点が要る |

---

## 7. 規約に違反したくなったとき

1. まず、規約が間違っている可能性を検討する
2. 規約が正しいなら、設計を変える。抑制で通さない
3. 抑制が要るなら、規則 ID と期限内の waiver を伴う 1 行の抑制にする（SWF-015）
4. 規則そのものを緩めるなら ADR を書く（QLT-010）
