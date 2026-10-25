# 用語集 — NeNe Sand

> Status: normative（規範）/ 2026-10-24 初版
> ここに載っている語は、コード、ドキュメント、Issue で同じ意味で使う。同義語を発明しない。

| 語 | 意味 | 型／場所 |
| --- | --- | --- |
| 粒 | 盤面の 1 マスにいる物質の個体 | NeNeSandCore（Phase 3） |
| 物質 | 砂、水、油、火、木、溶岩、石の閉じた種類 | NeNeSandCore の enum |
| 反応 | 隣り合う物質から次の状態を決める 1 行 | NeNeSandCore の表 |
| 盤面 | 粒の格子 | NeNeSandCore |
| tick | 盤面と進行を 1 歩進める純な遷移 | NeNeSandCore |
| 進行 | 解放済みの物質、通貨、装置、倍率 | NeNeSandCore |
| 回収口 | 粒が通貨になる唯一の入口 | NeNeSandCore |
| 通貨 | 回収した粒の値段に倍率を掛けた合計 | NeNeSandCore |
| 装置 | tick の中で動く盤面の住人 | NeNeSandCore |
| プレステージ | 盤面と通貨と装置を手放して得る恒久倍率 | NeNeSandCore |
| セル | 半角ブロックで描く 1 マス | NeNeSandRender |
| 合成ルート | 依存を結ぶ唯一の場所。コマンド名は `nene-sand` | NeNeSandApp |
| セーブ | 進行と、火と石の印の版つき文字列。盤の粒は含まない。ファイルの読み書きは合成ルートだけ | NeNeSandSave と NeNeSandApp |
| 結果（outcome） | 期待される成功と失敗を表す閉じた型 | `*Outcome` |
| ポート（port） | 中核がプラットフォームを使うための型のある窓口 | `*Port` |
| アダプタ（adapter） | ポートの実装 | NeNeSandTerminal と NeNeSandApp |
| 隔離区画 | 可変性を許した場所 | ARC-005 の表 |
| 規約検査（conformance） | このリポジトリ固有の自作ゲート | `eng/conformance.py` |
| waiver | 1 つの規則に対する期限付きの狭い例外 | `docs/waivers/WVR-NNNN-*.md` |
| 機械強制の状態 | active / planned / 不能 / 不採用 | `docs/QUALITY_GATES.md` の強制マトリクス |
| negative proof | ゲートが意図した規則で落ちることの実測 | `docs/quality/gate-proofs.md` |

## 使ってはいけない語

`Manager`、`Helper`、`Util`、`Utils`、`Common` を型名の語尾に使わない（SWF-010）。役割を語る名前が思いつかないときは、その型が 2 つの責務を持っている可能性が高い。
