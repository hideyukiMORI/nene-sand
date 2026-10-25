# NeNe Sand

Draw sand with the mouse and watch it fall, in the terminal. The command is `nene-sand`.

**English** · [日本語](README.ja.md)

![Sand, water, oil, fire, wood, lava, and stone](docs/images/playing.png)

Sand falls and piles up. Water flows downhill. Oil floats on water. Fire rises and goes out. Wood stays where it is placed. Lava flows slowly, and turns to stone when it touches water.

The picture above is free play (`m`). In progression, the bottom-center cell is a collector, and a grain that lands there becomes money.

## Install

Ubuntu 22.04 or newer, x86_64. Swift is not required.

```bash
curl -fsSL https://raw.githubusercontent.com/hideyukiMORI/nene-sand/main/install.sh | bash
```

This downloads the latest [release](https://github.com/hideyukiMORI/nene-sand/releases/latest), checks it against `SHA256SUMS`, and only then installs `~/.local/bin/nene-sand`. If the checksum does not match, nothing is installed. The script is [install.sh](install.sh). Read it before you pipe it.

If `~/.local/bin` is not on `PATH`, the script says so and stops. On many Ubuntu installs it is added at the next login. To remove it: `rm ~/.local/bin/nene-sand`.

The executable carries the Swift standard library inside. The only dynamic libraries it needs are libc, libstdc++, libgcc, and libm.

<details>
<summary>Install by hand</summary>

```bash
v=0.1.0
curl -fsSL -O https://github.com/hideyukiMORI/nene-sand/releases/download/v$v/nene-sand-linux-x86_64 \
           -O https://github.com/hideyukiMORI/nene-sand/releases/download/v$v/SHA256SUMS
sha256sum --check SHA256SUMS
install -Dm755 nene-sand-linux-x86_64 ~/.local/bin/nene-sand
```

</details>

## Keys

Draw with the left mouse button. Erase with the right. `[` and `]` set a square brush of 1, 3, or 5 cells.

| Key | What it does |
| --- | --- |
| `1` `2` | Sand and water. Available from the start |
| `3` `5` `6` | Buy oil for 40, wood for 20, and lava for 80. Nothing happens if you cannot pay |
| `4` | Fire. Drawable after lava ignites oil or wood |
| `7` | Stone. Drawable after water and lava make stone |
| `f` | Buy the faucet once, for 60. One water grain drips into an empty top-center cell |
| `a` | Automatic drawing. In progression, the end of a stroke buys the next grain you can afford, then the faucet |
| `Space` | Pause the grains and automatic drawing. Drawing and erasing still work |
| `c` | Clear every grain. Money, purchases, and the fire and stone marks stay |
| `m` | Free play. Every material can be drawn. Money does not increase, and the faucet does not drip |
| `k` | Codex. Open grains show their sell price. The simulation pauses while it is open |
| `t` | Cycle twelve themes. Water stays blue in every theme |
| `p` | With at least 100, press twice to give up the board, the purse, and the faucet, and raise the sell multiplier by 1 |
| `q` | Quit. Saves purchases, the purse, the multiplier, the faucet, and the fire and stone marks. The grains are not saved |

`Ctrl+C` saves and restores the terminal, the same as `q`.

## Rules

- Sell prices are sand 1, water 2, stone 4, wood 8, oil 16, fire 0, lava 32, times the prestige multiplier
- Fire is not for sale. It unlocks only when lava ignites oil or wood
- Stone forms when lava touches water on a side. A diagonal touch does not
- Fire spreads to oil and wood, and water puts it out. Lava also ignites oil and wood
- Once you own the faucet, covering the top-center cell only holds the next drop until that cell is empty again
- A locked codex entry shows `..`. An owned faucet shows `on`
- The save file is `$XDG_DATA_HOME/nene-sand/save`, or `~/.local/share/nene-sand/save`
- Closing the window without `q` or `Ctrl+C` drops whatever happened since the last save

![The codex in free play, with every grain open](docs/images/codex.png)

## Development

Done means this one command:

```bash
make check
```

The Swift version lives only in `.swift-version`. To build the same executable from source, in a directory other than the gate's:

```bash
swift build -c release --static-swift-stdlib
```

The development handbooks are [CLAUDE.md](CLAUDE.md) and [AGENTS.md](AGENTS.md). The release steps are the release section of [docs/DEVELOPMENT_WORKFLOW.md](docs/DEVELOPMENT_WORKFLOW.md).
