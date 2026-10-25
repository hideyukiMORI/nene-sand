# CLAUDE.md — NeNe Sand

Claude Code / AI エージェントがこのリポジトリで作業するための中核ハンドブック。
簡潔な英語版の入口は [AGENTS.md](AGENTS.md)。詳細の正本は `docs/` にあり、ここには複製しない。

---

## 0. まず読むもの（production コードに触れる前に必ず）

1. [docs/ARCHITECTURE_CONSTITUTION.md](docs/ARCHITECTURE_CONSTITUTION.md) — 憲章（ARC-001 から ARC-012）
2. [docs/PROJECT_LAYOUT.md](docs/PROJECT_LAYOUT.md) — モジュールと依存方向
3. [docs/CODING_RULES.md](docs/CODING_RULES.md) — Swift 規約（SWF-001 から SWF-015）
4. [docs/QUALITY_GATES.md](docs/QUALITY_GATES.md) — いま何が機械で守られているか
5. [docs/DEVELOPMENT_WORKFLOW.md](docs/DEVELOPMENT_WORKFLOW.md) — 手順
6. [docs/COMMIT_CONVENTIONS.md](docs/COMMIT_CONVENTIONS.md) — Issue、ブランチ、コミット、PR
7. [docs/GLOSSARY.md](docs/GLOSSARY.md) — 用語
8. 該当する ADR（`docs/adr/`）と有効な waiver（`docs/waivers/`）

---

## 1. このリポジトリの統治原則

> **一つの意味には一つの正典経路しか無い状態を作り、それを人の記憶ではなく機械に守らせる。**

その帰結として、次の 3 つを常に守る。

1. 正典の経路を先に特定してから編集する（ARC-001 / ARC-012）
2. ゲートを弱めて通さない。検査が落ちたらコードを直す（QLT-010）
3. `planned` を `active` と書かない（[ADR 0001](docs/adr/0001-strictness-is-mechanically-enforced.md)）

---

## 2. このプロジェクトで間違えやすい所

### 現在時刻を読む場所は 1 つしかない

現在時刻、乱数、既定ロケール、環境変数を読んでよいのは **NeNeSandApp** だけである（ARC-007）。中核で必要なら、値を引数で渡す。テストが実時刻を読むことも決定性の破壊である。

### 網羅性検査を殺す分岐を書かない

閉じた選択肢の分岐に `default`、`case _`、`@unknown default` を書かない（SWF-002）。ケース漏れはコンパイラが止め、この 3 つは CNF-009 が止める。

### 期待される失敗は例外にしない

検証エラー、読めないセーブ、拒否は閉じた結果型で返す（ARC-010 / SWF-005）。

### 空の enum は製品の型ではない

各ターゲットにある空の enum は、依存グラフをコンパイル可能にするための錨である。意味のある型を置く変更で、同じ変更のなかで消す。

---

## 3. 検証コマンド

```bash
make check
```

開発中は最も狭い検査を使ってよい。フルゲートは PR を Draft から Ready にする直前に必ず通す。

`make check` が通っていないものを「できた」と報告しない。実行していないコマンドの結果を書かない。テストの失敗を隠さない。

---

## 4. 変更の進め方

[docs/DEVELOPMENT_WORKFLOW.md](docs/DEVELOPMENT_WORKFLOW.md) が正本である。

Issue、正典経路の特定、ブランチ、設計を変えるなら先に ADR、最小の実装、テスト、狭い検査、`make check`、規則 ID ごとの自己レビュー、draft の PR、Ready、squash merge。

コミットは `type(scope): 日本語 (#N)`。形の正本は GIT-003。

---

## 5. 完了報告の形

```text
Issue / 規則 ID:
変更したファイルと振る舞い:
実行した検証コマンドと結果:
ドキュメント・スキーマの変更:
Waivers: none | WVR-NNNN
残るリスク:
```

調査だけを頼まれたときは、編集、コミット、push、PR 作成、外部状態の変更を行わない。

---

## 6. いまの状況

現在のタスクは [docs/todo/current.md](docs/todo/current.md)。GitHub Issue が正で、そこは要約。

動くのは `make check` と、砂と水と油と火と木と溶岩を描く版である。`a` で自動描画を切り替え、砂と水と油と火と木と溶岩が線ごとに入れ替わる。火は油と木に燃え移り、水で消える。溶岩は水よりゆっくり流れ、油と木に火をつける。水に触れた溶岩は石になり、石は落ちて溜まる。初めて石ができてから `7` で石を描ける。右クリックは、左クリックと同じ道を空にする。`c` で盤の粒を全部消す。`Space` で粒の流れと自動描画が止まり、マウスで置くことと消すことはできる。`[` `]` で筆は 1、3、5 マスの正方形になる。`m` で自由に遊ぶと、反応の前でも石を描ける。盤の上に 3 行、下に 3 行の英語の計器が出る。色見本と状況と冗談と、キーの説明である。`t` で計器の色が緑と琥珀で切り替わる。粒の色は変わらない。進行、セーブはまだ無い。
