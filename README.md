# NeNe Sand

WSL の Ubuntu 端末で、マウスで砂を描いて遊ぶシミュレーター。Swift 製。コマンド名は `nene-sand`。

このリビジョンは、砂と水と油と火と木を描く版と、それを守るゲートである。`a` で勝手に描き、砂と水と油と火と木が線ごとに入れ替わる。火は油と木に燃え移り、水で消える。溶岩、進行、セーブはまだ無い。

完了の定義は次の 1 コマンドである。

```bash
make check
```

Swift の版は `.swift-version` だけに書く。開発の入口は [CLAUDE.md](CLAUDE.md) と [AGENTS.md](AGENTS.md)。
