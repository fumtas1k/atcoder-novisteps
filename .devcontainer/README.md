# Dev Container (AtCoder 環境)

acc / oj / Ruby を丸ごと再現するための Dev Container 定義。
VS Code の「Dev Containers」拡張、GitHub Codespaces、または `devcontainer` CLI で開く。

## 含まれるもの

| ツール | バージョン | 入れ方 |
|---|---|---|
| Ruby | 3.4.5（`.ruby-version` と一致） | devcontainer feature |
| Node.js | LTS | devcontainer feature（acc 用） |
| uv | latest | devcontainer feature |
| oj (online-judge-tools) | 11.5.1 (+ api-client 10.10.1) | `uv tool install`。未マージ修正 PR #173 をパッチ適用（下記） |
| acc (atcoder-cli) | 2.2.0 | `npm install -g` |
| gem | Gemfile.lock 準拠 | `bundle install` |

これらは `postCreateCommand` でコンテナ生成時に自動導入される。

## 初回だけやること：ログイン（Cloudflare 対応）

現在の AtCoder はログイン時に Cloudflare のチェックが入るため、コンテナ内からの
`oj login` / `acc login` は通らない。代わりに **ブラウザで取得した `REVEL_SESSION`
Cookie を oj と acc の両方に流し込む**（ヘルパースクリプトが両方に書き込む）。

- oj  : `~/.local/share/online-judge-tools/cookie.jar`（LWPCookieJar 形式）
- acc : `~/.config/atcoder-cli-nodejs/session.json`（`{"cookies":["name=value",...]}`）

認証はマシンごとの秘密なのでイメージには含めない。
（どちらも名前付き volume に永続化されるので、以降のリビルドでは再取得不要。）

1. 普段のブラウザで AtCoder にログイン（Cloudflare を通過しておく）
2. DevTools → Application/Storage → Cookies → `https://atcoder.jp` → **`REVEL_SESSION` の Value をコピー**
3. コンテナ内ターミナルで:

   ```sh
   uv run --no-project .devcontainer/set-atcoder-session.py
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

## 言語を増やすとき

- ランタイムを `devcontainer.json` の `features` に追加（例: Go, C++ など）
- `oj test -c "<実行コマンド>"` の `-c` を変えるだけで多言語のテストに対応できる

## oj のパッチについて（PR #173）

現行の api-client 10.10.1 は AtCoder のメモリ表記変更（KB/MB → KiB/MiB）に未対応で、
問題データ取得時に `AssertionError` で止まる。上流の未マージ修正
[online-judge-tools/api-client#173](https://github.com/online-judge-tools/api-client/pull/173)
を、公式版インストール後に `oj-atcoder-memory.patch` として `post-create.sh` が当てている
（第三者 fork は使わず、公式 PyPI 版＋差分パッチのみ）。適用は冪等。

**上流にマージされたら**、`post-create.sh` のパッチ適用ブロックと
`oj-atcoder-memory.patch` を削除し、`online-judge-api-client` のバージョンピンを見直すこと。
