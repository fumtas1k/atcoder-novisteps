#!/usr/bin/env bash
# devcontainer 生成時のセットアップ。冪等(再実行しても安全)。
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"

# volume マウントで root 所有になる ~/.local ~/.config ~/.claude を vscode に戻す
# (これがないと uv や claude が書き込めず Permission denied)。
sudo chown -R vscode:vscode "$HOME/.local" "$HOME/.config" "$HOME/.claude"

# Claude Code CLI(公式 feature)は root 所有でグローバル導入されるため、
# vscode ユーザーだと自動アップデートが Permission denied で失敗する。
# npm グローバル領域を vscode 所有に戻して自動更新をそのまま通す(冪等)。
npm_prefix="$(npm config get prefix)"
sudo chown -R vscode:vscode "$npm_prefix/lib/node_modules" "$npm_prefix/bin"

# oj / acc / AtCoder メモリ表記パッチは devcontainer feature
# ghcr.io/fumtas1k/devcontainer-features/atcoder-toolkit がビルド時に導入済み。

# statusLine スクリプト(.claude/statusline-command.sh)が使う jq を用意(未導入なら)。
if ! command -v jq >/dev/null 2>&1; then
  sudo apt-get update && sudo apt-get install -y --no-install-recommends jq
fi

# acc の既定設定・テンプレート(ruby)を配置。
# config.json / ruby テンプレを上書きし、session.json(認証)は残す。
# oj-path は含めない → acc は PATH 上の oj を使う。
mkdir -p "$HOME/.config/atcoder-cli-nodejs"
cp -r "$here/acc-config/." "$HOME/.config/atcoder-cli-nodejs/"

# gem(ac-library-rb / rbtree / numo-narray / ruby-lsp)は devcontainer feature
# ghcr.io/fumtas1k/devcontainer-features/atcoder-ruby がビルド時にグローバル導入済み。

# シェルヘルパー(atcr / rtest / ropen)を bash で有効化。
# ~/.bashrc は volume 非永続でリビルドのたびに再生成されるので、毎回 source 行を追記。
# repo 管理の shell-aliases.sh を指すので、エイリアスの実体は版管理される。
source_line="source \"$here/shell-aliases.sh\""
if ! grep -qF "$source_line" "$HOME/.bashrc" 2>/dev/null; then
  printf '\n# AtCoder shell helpers (devcontainer)\n%s\n' "$source_line" >> "$HOME/.bashrc"
  echo "added shell-aliases source line to ~/.bashrc"
fi
