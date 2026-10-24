# コミットとリポジトリの規約 — NeNe Sand

> Status: normative（規範）/ 2026-10-24 初版

変更の経路は一つである。Issue から、焦点を持つブランチ、一貫したコミット、PR、必須 check、squash merge、同期した `main` へ進む。

読み方は [ARCHITECTURE_CONSTITUTION.md](ARCHITECTURE_CONSTITUTION.md) 第 0 節と同じ。

---

### GIT-001 — すべての変更は 1 つの Issue から始まる

Issue には問題と根拠、意図する結果、影響する規則 ID とモジュール、受け入れ条件、検証の計画、やらないことを書く。読み取りだけの調査は Issue 無しでよい。初期化コミットだけが Issue 番号の例外である。Issue の中身が妥当かは機械では見ない。

- 機械強制: **planned**（`.github/pull_request_template.md` が形を示す。本文を CI はまだ検査しない）

### GIT-002 — ブランチ名は一つの形

```text
<type>/<issue番号>-<short-kebab-summary>
```

`type` は `feat` / `fix` / `docs` / `refactor` / `test` / `build` / `ci` / `chore` のいずれかである。例: `build/1-strict-foundation`。`main` での直接開発、force push、既定ブランチの削除は禁止する。

- 機械強制: **active**（`eng/commit_message.py`。CI は `PR_HEAD` を渡す。`main` は検査しない）

### GIT-003 — コミットメッセージは一つの形

```text
<type>(<scope>): <日本語の説明> (#<issue番号>)
```

- `type` は GIT-002 と同じ集合である
- `scope` は小文字で、省略できる
- 説明には日本語（ひらがな、カタカナ、漢字）を 1 文字以上入れる
- 件名は 100 文字以内で、末尾に `(#N)` を付ける
- 互換性を壊す公開契約の変更は `:` の前に `!` を付け、フッタに `BREAKING CHANGE:` を書く
- 件名には判断を置く

squash merge の件名も同じ形にする。PR タイトルも同じ検査にかける。

- 機械強制: **active**（`.githooks/commit-msg` と `make check` が同じ `eng/commit_message.py` を呼ぶ。CI は `PR_TITLE` を渡す。フックは `eng/bootstrap.sh` でこのクローンの `core.hooksPath` だけを向ける）

### GIT-004 — PR が統合の境界

PR には目的、変更の要約、使った正典経路、規則 ID、検証結果、waiver、残るリスク、`Closes #N` を書く。1 つの PR に 1 つの作業単位を置く。マージは squash だけとする。

実装中とレビュー中は draft である。Draft から Ready にするときがフルゲートの要求である。

- 機械強制: **planned**（テンプレートと、ruleset を設定したあとの squash 限定。設定の読み戻しは gate-proofs に書く）

---

## フックの導入

フックはリポジトリが所有する。clone の直後に 1 回、次を実行する。

```bash
bash eng/bootstrap.sh
```

このスクリプトは、このクローンの `core.hooksPath` を `.githooks` に向ける。グローバルの git 設定は変えない。フックはコミットメッセージだけを見て、フルゲートの代わりにならない。`--no-verify` で迂回できるので、`make check` と CI が同じ検査を通して初めて GIT-003 を active にしている。
