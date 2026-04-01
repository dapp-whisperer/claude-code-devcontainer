# Unified Theming System

This directory is the source of truth for cross-tool theming in this dotfiles repo.

The `theme` command (`scripts/theme`) applies one named theme across terminal apps, editors, CLIs, and OpenCode.

## How It Works

- Theme packs live at `themes/<theme-name>/`
- Active theme name is stored in `themes/current`
- Each pack has `manifest.toml` with per-tool theme mappings
- `scripts/theme` reads the manifest, updates stowed config files, and copies overlay files where needed
- Some apps auto-reload; others require restart (reported by the script after switching)

## Directory Contract

Each `themes/<theme-name>/` directory should contain:

- `manifest.toml` - required key mapping for all integrated tools
- `delta.gitconfig`
- `fzf-theme.sh`
- `eza-theme.yml`
- `lazygit-theme.yml`
- `lazydocker-theme.yml`
- `gitui-theme.ron`
- `btop.theme`
- `yazi-theme.toml`
- `bat.tmTheme`
- `tmux-theme.conf` — catppuccin `@thm_*` palette variables + outer status bar colors, pane borders, and copy-mode highlight
- Optional: `zellij-colors.kdl` for custom Zellij theme definitions

## Manifest Keys

`manifest.toml` must define these keys:

- `name`
- `variant` (`dark` or `light`)
- `font` (Ghostty `font-family`, e.g. `"JetBrains Mono"` or `"IBM Plex Mono"`)
- `ghostty`
- `helix`
- `zellij`
- `btop`
- `neovim`
- `delta`
- `bat`
- `tmux`
- `opencode`
- `wezterm` (WezTerm built-in color scheme name)
- `wezterm_font` (full Lua `wezterm.font` expression, e.g. `"wezterm.font 'JetBrainsMono Nerd Font Mono'"`)
- `wezterm_bg` (6-digit hex background overlay color, no `#` prefix)

Example:

```toml
name = "Catppuccin Mocha"
variant = "dark"
font = "JetBrains Mono"
ghostty = "Catppuccin Mocha"
helix = "catppuccin_mocha"
zellij = "catppuccin-mocha"
btop = "catppuccin_mocha"
neovim = "catppuccin-mocha"
delta = "catppuccin-mocha"
bat = "Catppuccin Mocha"
tmux = "mocha"
opencode = "catppuccin-mocha-glass"
wezterm = "Catppuccin Mocha"
wezterm_font = "wezterm.font 'JetBrainsMono Nerd Font Mono'"
wezterm_bg = "1e1e2e"
```

## Commands

```bash
# Show current + available themes
theme

# Switch theme
theme catppuccin-mocha
theme tokyonight-night
```

## OpenCode Integration

- OpenCode theme is set by `manifest.toml` key `opencode`
- `scripts/theme` writes that value into `opencode/.config/opencode/opencode.json` (`"theme"` field)
- Custom OpenCode theme definitions live in `opencode/.config/opencode/themes/`
- Current custom glass preset: `catppuccin-mocha-glass.json`

When adding a new OpenCode theme:

1. Add the JSON theme file under `opencode/.config/opencode/themes/`
2. Reference its theme ID in each relevant `themes/<theme>/manifest.toml` via `opencode = "..."`
3. Run `theme <name>` and verify OpenCode picks it up after restart

## For Coding Agents (Important)

If you modify `scripts/theme` or theme assets, follow these rules.

- Do not use `sed -i` for watched stow-managed files on macOS.
- Preserve inode for existing destination files when editing/copying watched configs.
- Prefer read-modify-write (`content="$(sed ...)"; printf ... > file`) over tools that replace files.
- For existing watched destination files, prefer `cat src > dst` over `cp src dst`.
- Keep `manifest.toml` schema expectations aligned with parser logic in `scripts/theme`.
- Validate inputs; keep theme names restricted to safe characters.
- Preserve best-effort reload behavior (`|| true`) to avoid partial failure during theme switch.

Background: macOS file watchers and stow symlinks can miss updates when inode changes. See `docs/solutions/integration-issues/macos-sed-inode-file-watcher-symlink-reload.md`.

## Add a New Theme Checklist

1. Copy an existing pack (for example `themes/catppuccin-mocha`) to a new directory.
2. Update `manifest.toml` mappings for every required key.
3. Replace theme asset files (`delta.gitconfig`, `fzf-theme.sh`, etc.) with matching values.
4. Run `theme <new-theme>`.
5. Verify:
   - `themes/current` changed
   - config values were updated in stowed sources
   - apps that should auto-reload do so
   - restart-required apps reflect the new theme after restart

## Troubleshooting

- Theme appears unchanged in Ghostty: run `theme <name>` again and ensure Ghostty accessibility/menu reload is allowed.
- btop reverts theme: ensure `save_config_on_exit = false` in `btop/.config/btop/btop.conf`.
- OpenCode theme not visible: confirm theme JSON exists and `opencode` manifest value matches its ID.
- fzf colors unchanged: open a new shell session (theme script reports this).
