<h3 align="center">
Neovim config ⚡</h3>

---

### What's this?

My personal Neovim config — minimal, fast, and opinionated. Uses lazy.nvim for plugin management with LSP, snacks.nvim, Treesitter, and formatting out of the box.

### How to install?

```sh
# Back up existing config if any
mv ~/.config/nvim ~/.config/nvim.bak

# Clone and open
git clone git@github.com:ArunGovil/dotfiles.git ~/.config/nvim
nvim
```

Lazy.nvim will auto-install all plugins on first launch. Mason will set up language servers and formatters.

> **Note**
> Requires Neovim >= 0.10 and git. Project formatters must be installed separately.

### Formatting

JS and TS files use the nearest Oxfmt, Biome or Prettier config (in that order
for ties). CSS, HTML, JSON and Markdown use Prettier when configured. Install the
selected formatter locally or on PATH. Without a matching config, formatting uses
an available LSP; a missing configured formatter won't fall back.

Format on save or with `<leader>F`. Use `:ConformInfo` to check the selected
formatter and its availability.
