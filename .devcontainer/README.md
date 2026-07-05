# Dev Container (AtCoder 環境)

acc / oj / Ruby を丸ごと再現するための Dev Container 定義。
VS Code の「Dev Containers」拡張、GitHub Codespaces、または `devcontainer` CLI で開く。

## 含まれるもの

| ツール | バージョン | 入れ方 |
|---|---|---|
| Ruby | 3.4.5（`.ruby-version` と一致） | devcontainer feature |
| Node.js | LTS | devcontainer feature（acc 用） |
| uv | latest | devcontainer feature |
| oj (online-judge-tools) | 11.5.1 | `uv tool install`（実行用 Python は uv が自動用意） |
| acc (atcoder-cli) | 2.2.0 | `npm install -g` |
| gem | Gemfile.lock 準拠 | `bundle install` |

これらは `postCreateCommand` でコンテナ生成時に自動導入される。

## 初回だけやること：ログイン

認証 Cookie はマシンごとの秘密なのでイメージには含めない。コンテナ内ターミナルで一度だけ実行する。
（Cookie は名前付き volume に永続化されるので、以降のリビルドでは再ログイン不要。）

```sh
oj login https://atcoder.jp/
acc login
```

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
