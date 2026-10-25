# NeNe Sand

WSL の Ubuntu 端末で、マウスで砂を描いて遊ぶシミュレーター。Swift 製。コマンド名は `nene-sand`。

このリビジョンは、砂と水を描いて落とす版と、それを守るゲートである。`a` で、いまの筆が勝手に描く。油、火、木、溶岩、反応、進行、セーブはまだ無い。

完了の定義は次の 1 コマンドである。

```bash
make check
```

Swift の版は `.swift-version` だけに書く。開発の入口は [CLAUDE.md](CLAUDE.md) と [AGENTS.md](AGENTS.md)。
