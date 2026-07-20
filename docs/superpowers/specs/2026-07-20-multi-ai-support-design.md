# 複数AI対応（Codex など）への共通化 — 設計

作成日: 2026-07-20

## 目的

現在 Claude Code 専用になっている本リポジトリの設定を、`atcoder-ndpc` と同じ構成に
そろえ、**Codex CLI をはじめとする他のコーディングAIでも同じ指示・スキルを使える**
ようにする。フォルダ移動・シンボリックリンク・指示ドキュメントの共通化で実現する。

参考: [`fumtas1k/atcoder-ndpc`](https://github.com/fumtas1k/atcoder-ndpc) の同構成。

## ユーザー決定事項

- **GEMINI.md は作らない**（Gemini も AGENTS.md を読むため不要、という判断）。
- **Node は `"lts"` のまま**（`.node-version` は作らない、devcontainer の node feature も据え置き）。

## 変更内容

### A. 指示ドキュメントの共通化（唯一のソース = AGENTS.md）

- **`AGENTS.md`（新規）**: 現 `CLAUDE.md` の中身をそのまま移す。冒頭に
  `atcoder-ndpc` と同じ「ユーザーとのやり取りは常に日本語で行う」ディレクティブを
  1 セクション追加する。それ以外の本文（このリポジトリについて / Claude の役割 /
  レビュー時の手順 / ディレクトリ構成 / ワークフロー / 解答規約 / README 更新）は
  現行のまま維持する。
  - 「Claude Code の役割」等の見出しは現行の文面を尊重して残す（agent 中立の細かな
    言い換えは今回スコープ外。`atcoder-ruby スキル` への参照もそのまま）。
- **`CLAUDE.md`**: 内容を 1 行 `@AGENTS.md` に置き換える（Claude Code の import 構文）。
  これで Claude は AGENTS.md を読み込む。

### B. スキルの共通化（実体を .agents/ に、.claude/ からはシンボリックリンク）

- `git mv .claude/skills/atcoder-ruby .agents/skills/atcoder-ruby` で実体を移動
  （`SKILL.md` / `evals/` / `references/` 一式）。
- `.claude/skills/atcoder-ruby` を `../../.agents/skills/atcoder-ruby` を指す
  シンボリックリンクとして作成（`ln -s`）。Claude は従来どおりスキルを解決できる。
- `.claude/settings.json` と `.claude/statusline-command.sh` は変更しない。

### C. devcontainer に Codex CLI を追加

- **`.devcontainer/devcontainer.json`**:
  - `mounts` に `source=atcoder-codex,target=/home/vscode/.codex,type=volume` を追加
    （Codex の認証・設定をリビルドで消えないよう永続化）。
  - node feature は `"lts"` のまま（変更なし）。
- **`.devcontainer/post-create.sh`**:
  - `chown -R vscode:vscode` の対象に `$HOME/.codex` を追加。
  - `command -v codex` が無ければ `npm install --global @openai/codex` を実行（冪等）。
  - **既存の jq インストールブロック（statusLine が使う）は残す**。既存の acc 設定配置・
    shell-aliases 読み込みもそのまま。

### D. `.npmrc`（新規, ルート）

- Codex を `npm i -g` する際のサプライチェーン安全策として `atcoder-ndpc` と同じ:
  ```
  ignore-scripts=true
  min-release-age=7
  ```
- （spec レビューで不要と判断されれば省略可。node 固定とは独立の項目。）

### E. README への追記

- **`.devcontainer/README.md`**: Codex CLI の導入場所（post-create で npm 導入、
  `~/.codex` volume で認証永続化）、初回 `codex` ログイン手順、AGENTS.md /
  シンボリックリンクの仕組みを短く追記。

## スコープ外（今回やらないこと）

- `GEMINI.md` の追加（ユーザー判断）。
- Node バージョン固定・`.node-version` の追加（ユーザー判断）。
- `Gemfile` / `Gemfile.lock` の追加（ndpc にはあるが、Codex 有効化とは無関係の
  ローカル開発用途のため今回は入れない）。
- `atcoder-ruby` スキル本文の agent 中立化リライト（参照名の言い換え等）。

## 検証

- `cat CLAUDE.md` が `@AGENTS.md` のみであること。
- `readlink .claude/skills/atcoder-ruby` が `../../.agents/skills/atcoder-ruby` を返し、
  `.claude/skills/atcoder-ruby/SKILL.md` がリンク越しに読めること。
- `.agents/skills/atcoder-ruby/SKILL.md` 等が git 上で実体として追跡され、
  `.claude/skills/atcoder-ruby` が mode 120000（symlink）で追跡されること。
- devcontainer リビルド後（またはローカルで）`command -v codex` が通り、
  `post-create.sh` が冪等に再実行できること（`bash .devcontainer/post-create.sh`）。
- `rtest` / `atcr` / statusLine（jq）が従来どおり動くこと。
