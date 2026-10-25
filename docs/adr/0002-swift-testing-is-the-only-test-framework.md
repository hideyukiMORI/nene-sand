# ADR 0002 — 製品テストは Swift Testing だけ

- 状態: 受理
- 日付: 2026-10-24
- Issue: #1
- 影響する規則: QLT-008、QLT-009

## 文脈

テスト枠組みは 1 つに決める。Swift 6.4.1 で、テストが 1 本も無いパッケージの `swift test` は `error: no tests found` で終了 1 だった。同じツールチェーンの Swift Testing（Testing Library Version 6.4.1）で `@Test` を 1 件書くと、その 1 件は成功した。

製品の振る舞い（盤面、tick、反応、進行）は、この Issue では書かない。意味の無いテストを足して `swift test` を緑にすることは、ゲートの成功を偽る。

## 決定

製品のテストは Swift Testing だけを使う。XCTest は足さない。振る舞いを持つ最初の変更まで `Tests/` は置かず、`make check` は `swift test` を呼ばない。それまでのゲートのテストは、規約検査の単体テスト（`eng/test_conformance.py` と `eng/test_commit_message.py`）である。

カバレッジ下限は、中核に分岐ができてから測って置く。いまは置いていない（QLT-009）。

## 強制

- active: 規約検査の単体テストは `make check` から呼ばれる（QLT-007）
- planned: 製品テストの存在そのもの（QLT-008）。振る舞いを足す PR が、Swift Testing のテストを同じ変更で足す

## 結果

得られるもの:

- テスト枠組みが 2 つに割れない
- 空の `swift test` がゲートを赤くしない

失うもの:

- この Issue のゲートは、砂が正しく落ちることを証明しない

## 却下した選択肢

| 選択肢 | 却下の理由 |
| --- | --- |
| XCTest | Swift 6 のテスト枠組みが 2 つあるときに、古いほうを第二の経路として残さない。Swift Testing は同じツールチェーンで起動した |
| XCTest と Swift Testing の併用 | 1 つの意味に 2 つの経路ができる |
| 錨の enum を参照するだけのテストを足して `swift test` を結線する | テスト 0 件が終了 1 になることへの回避であり、振る舞いを守らない |
| いまカバレッジ下限を 90 などと書く | 測っていない数字を規範にしない |

## 関連

- ADR 0001
