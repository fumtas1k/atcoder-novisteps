# Dev Container (AtCoder 環境)

acc / oj / Ruby を丸ごと再現するための Dev Container 定義。
VS Code の「Dev Containers」拡張、GitHub Codespaces、または `devcontainer` CLI で開く。

## 含まれるもの

| ツール | バージョン | 入れ方 |
|---|---|---|
| Ruby | 3.4.5（`.ruby-version` と一致） | devcontainer feature |
| Node.js | LTS | devcontainer feature（acc 用） |
| oj (online-judge-tools) | 11.5.1 (+ api-client 10.10.1) | 自作 feature [atcoder-toolkit](https://github.com/fumtas1k/devcontainer-features)。未マージ修正 PR #173 をパッチ適用（下記） |
| acc (atcoder-cli) | 2.2.0 | 同上（atcoder-toolkit feature） |
| gem (ac-library-rb 1.2.0 / rbtree 0.4.7 / numo-narray 0.9.2.1 / ruby-lsp) | `devcontainer.json` の `gems` オプションで固定 | 自作 feature [atcoder-ruby](https://github.com/fumtas1k/devcontainer-features)。グローバル導入なので `bundle exec` 不要（ジャッジ環境と同じ） |
| Claude Code CLI | 最新 | 公式 devcontainer feature（VS Code 拡張も同梱） |
| Codex CLI (`@openai/codex`) | 最新 | `post-create.sh` が `npm install --global`（公式 feature が無いため） |
| gh (GitHub CLI) | 最新 | 公式 devcontainer feature（PR 作成・マージ用） |

ツール類はすべて features としてイメージビルド時に導入される。`postCreateCommand`
（post-create.sh）に残るのは volume の chown・acc 設定配置・シェルエイリアスなど
リポ固有の仕上げのみ。

Claude Code は初回に `claude` を実行してログインする。ログイン情報は名前付き volume
（`~/.claude`）に永続化されるので、以降のリビルドでは再ログイン不要。

Codex CLI も同様に初回に `codex` を実行してログインする。設定・認証は名前付き volume
（`~/.codex`）に永続化されるので、以降のリビルドでは再ログイン不要。

### AI への指示ファイル（AGENTS.md）とスキルの共通化

Claude Code・Codex など複数の AI で同じ指示・スキルを共有するため、次の構成にしている:

- **`AGENTS.md`（リポジトリ直下）** … 唯一のソース。Codex はこれを直接読む。
- **`CLAUDE.md`** … 中身は `@AGENTS.md` の 1 行のみ。Claude Code の import 構文で
  AGENTS.md を取り込む。
- **`atcoder-ruby` スキル** … 実体は `.agents/skills/atcoder-ruby/`。
  `.claude/skills/atcoder-ruby` はそこへのシンボリックリンク（Claude はリンク越しに読む）。

指示やスキルを直したいときは `AGENTS.md` / `.agents/skills/` の実体を編集する。

gh (GitHub CLI) も PR 作成・マージに使うので初回に `gh auth login` する
（GitHub.com → HTTPS → ブラウザ認証）。認証はマシンごとの秘密なのでイメージには
含めないが、`~/.config/gh` を名前付き volume に永続化しているので、以降のリビルドでは
再ログイン不要。

## 初回だけやること：ログイン（Cloudflare 対応）

現在の AtCoder はログイン時に Cloudflare のチェックが入るため、コンテナ内からの
`oj login` / `acc login` は通らない。代わりに **ブラウザで取得した `REVEL_SESSION`
Cookie を oj と acc の両方に流し込む**（atcoder-toolkit feature 同梱の
`set-atcoder-session` コマンドが両方に書き込む）。

- oj  : `~/.local/share/online-judge-tools/cookie.jar`（LWPCookieJar 形式）
- acc : `~/.config/atcoder-cli-nodejs/session.json`（`{"cookies":["name=value",...]}`）

認証はマシンごとの秘密なのでイメージには含めない。
（どちらも名前付き volume に永続化されるので、以降のリビルドでは再取得不要。）

1. 普段のブラウザで AtCoder にログイン（Cloudflare を通過しておく）
2. DevTools → Application/Storage → Cookies → `https://atcoder.jp` → **`REVEL_SESSION` の Value をコピー**
3. コンテナ内ターミナルで:

   ```sh
   set-atcoder-session
   # プロンプトに REVEL_SESSION の値を貼り付ける
   ```

4. 確認:

   ```sh
   oj login --check https://atcoder.jp/
   ```

スクリプトは oj・acc 両方に同じ値を書くので、`acc new`（要ログインの一部機能含む）も
`acc submit` / `oj submit` も通る。値が切れたら手順 1〜3 を再実行する。

## 使い方（一例）

```sh
# 問題ディレクトリを生成（テストケースも DL）
acc new abc999

cd abc999/a
# a.rb を書く

# サンプルでテスト（Ruby 実行コマンドを指定）
oj test -c "ruby main.rb" -d tests

# 提出
acc submit main.rb
```

## acc の既定設定・テンプレート

`acc-config/` の内容を `post-create.sh` が `~/.config/atcoder-cli-nodejs/` に配置する
（`config.json` と `ruby` テンプレート）。これで `acc new` 時にディレクトリ命名や
既定テンプレートがホストと同じになる。`session.json`（認証）は上書きされず残る。

- `acc-config/config.json` … 命名フォーマット、`default-template: ruby` など。
  `oj-path` は含めない（コンテナは PATH 上の `oj` を使う）
- `acc-config/ruby/` … `main.rb`（ac-library-rb / rbtree などの雛形）と `template.json`

設定やテンプレを変えたいときは `acc-config/` を編集して再ビルド（または `post-create.sh`
の該当行を再実行）。

## 言語を増やすとき

- ランタイムを `devcontainer.json` の `features` に追加（例: Go, C++ など）
- `oj test -c "<実行コマンド>"` の `-c` を変えるだけで多言語のテストに対応できる

## oj のパッチについて（PR #173）

現行の api-client 10.10.1 は AtCoder のメモリ表記変更（KB/MB → KiB/MiB）に未対応で、
問題データ取得時に `AssertionError` で止まる。上流の未マージ修正
[online-judge-tools/api-client#173](https://github.com/online-judge-tools/api-client/pull/173)
を、[atcoder-toolkit feature](https://github.com/fumtas1k/devcontainer-features) が
ビルド時に公式 PyPI 版へ当てている（第三者 fork は使わない）。

**上流にマージされたら**、`devcontainer.json` の atcoder-toolkit feature で
`"applyAtcoderMemoryPatch": false` を指定し、`apiClientVersion` のピンを見直すこと。
