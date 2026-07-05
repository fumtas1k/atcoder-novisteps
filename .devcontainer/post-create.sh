#!/usr/bin/env bash
# devcontainer 生成時のセットアップ。冪等(再実行しても安全)。
set -euo pipefail

here="$(cd "$(dirname "$0")" && pwd)"

# volume マウントで root 所有になる ~/.local ~/.config ~/.claude を vscode に戻す
# (これがないと uv や claude が書き込めず Permission denied)。
sudo chown -R vscode:vscode "$HOME/.local" "$HOME/.config" "$HOME/.claude"

# oj: online-judge-api-client を 10.10.1 に固定して公式 PyPI から導入。
# uv tool install = pipx 相当。oj 実行用 Python は uv が自動で用意する。
uv tool install online-judge-tools==11.5.1 --with online-judge-api-client==10.10.1

# 未マージ修正 (online-judge-tools/api-client PR #173) を公式版に当てる。
# AtCoder のメモリ表記変更 (KB/MB → KiB/MiB) 未対応で AssertionError になるのを直す。
# 上流にマージされたら、この行と oj-atcoder-memory.patch を削除してよい。
site="$("$(uv tool dir)/online-judge-tools/bin/python" -c 'import onlinejudge, os; print(os.path.dirname(os.path.dirname(onlinejudge.__file__)))')"
if grep -q "KiB" "$site/onlinejudge/service/atcoder.py"; then
  echo "oj-atcoder-memory.patch already applied; skipping"
else
  git apply -p1 --unsafe-paths --directory="$site" "$here/oj-atcoder-memory.patch"
  echo "applied oj-atcoder-memory.patch to $site"
fi

# acc(atcoder-cli)
npm install -g atcoder-cli@2.2.0

# gem
bundle install
