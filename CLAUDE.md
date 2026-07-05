# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## このリポジトリについて

[AtCoder NoviSteps](https://atcoder-novisteps.vercel.app/problems) の問題を Ruby で解いた解答置き場。
アプリケーションのソースコードではなく、1問1ディレクトリの競技プログラミング解答集。

## Claude Code の役割

**問題を解くのは人間**。Claude Code は基本的に、人間が書いた解答（`main.rb`）を
**レビューし、改善する**役割。ゼロから解答を書くのがメインではない。

- 主なタスク: バグ・計算量（TLE/MLE リスク）の指摘、より速い/簡潔な書き方の提案、`ac-library-rb` で置き換えられる箇所の指摘、Ruby/CRuby 特有の落とし穴の指摘。
- Ruby コードをレビュー・改善・デバッグ・助言するときは、たとえ「自明に見えても」必ず **`atcoder-ruby` スキル** に従う（CRuby の計算量・イディオム・`ac-library-rb` の使い方が検証済みでまとまっている。`Array#shift`/`#unshift` の計算量など Claude が間違えやすい点も網羅）。
- 求められない限り、人間の解答を勝手に全面書き換えしない。まず指摘・提案してから直す。

### レビュー時は問題文と解説を必ず確認する

コードだけを見て推測でレビューしない。**まず問題文に当たり、次に公式解説（editorial）を辿って**、
「解答がその問題を正しく解いているか」「想定解法・想定計算量と合っているか」を確認したうえで指摘する。

ディレクトリ `problems/<グレード>/<contest>/<problem>/` から URL を導ける（`README.md` の一覧表にも直リンクがある）:

- 問題文: `https://atcoder.jp/contests/<contest>/tasks/<contest>_<problem>`
  例: `problems/1Q/abc436/d/` → `https://atcoder.jp/contests/abc436/tasks/abc436_d`
- 解説: 上の URL の末尾に `/editorial` を付ける（`.../tasks/abc436_d/editorial`）、
  またはコンテスト全体の解説一覧 `https://atcoder.jp/contests/<contest>/editorial`

`WebFetch` でこれらを取得して、制約（`N` の上限など）・入出力形式・想定計算量を確認する。
確認できた制約と解法をレビュー結果の根拠として示す。

## ディレクトリ構成

```
problems/<グレード>/<contest>/<problem>/
  main.rb          # 解答（ファイル名は必ず main.rb）
  tests/           # acc が DL したサンプル
    sample-1.in / sample-1.out / ...
```

- 例: `problems/1Q/abc436/d/main.rb`
- `<グレード>` は NoviSteps のグレード（`1Q` など）。`<problem>` は小文字のタスクラベル（`d` など）。
- 解答ファイル名は `<problem>.rb` ではなく **`main.rb`**（コミット `38be632` で統一済み。`acc` テンプレート・`rtest`・`ropen` すべて `main.rb` 前提）。

## 開発ワークフロー（Dev Container 内）

環境は `.devcontainer/` の Dev Container で再現する。詳細は `.devcontainer/README.md`。
`acc`(atcoder-cli) / `oj`(online-judge-tools) / Ruby 3.4.5 / `bundle` が入っており、
`.devcontainer/shell-aliases.sh` の関数が `~/.bashrc` から読み込まれている。

- **問題セットアップ**: `atcr <contest> <problem>`
  （`acc new <contest>` でテスト DL → `<contest>/<problem>` へ移動 → `main.rb` を開く）
- **サンプルテスト**: `rtest`
  （= `oj t -c "bundle exec ruby main.rb" -d tests -N`。`-N` で末尾改行差を無視）
- **単体実行**: `bundle exec ruby main.rb < problems/.../tests/sample-1.in`
- **提出**: `acc submit main.rb`（または `oj submit`）

`acc new` は要ログイン。認証は Cloudflare 対策で `oj/acc login` が通らないため、
ブラウザで取得した `REVEL_SESSION` Cookie を
`uv run --no-project .devcontainer/set-atcoder-session.py` で流し込む（`.devcontainer/README.md` 参照）。

## 解答の規約（レビュー時の前提）

人間の解答は `acc new` の Ruby テンプレート（`.devcontainer/acc-config/ruby/main.rb`）を雛形にしている。
レビュー・改善時はこの慣習を前提にする:

- 先頭で `ac-library-rb`（dsu / segtree / priority_queue / fenwick_tree）・`rbtree`・`set` を require し `include AcLibraryRb`
- 定義済みヘルパー: `inside?(r, c, h, w)`（グリッド範囲判定）、`bsearch(ng, ok) { ... }`（二分探索）
- 定数: `MOD`（既定 `10**9+7`、`998244353` はコメントアウトで用意）、`INF = 1 << 60`
- 入力は `gets` / `gets.split.map(&:to_i)` 系。既存解答（`problems/1Q/abc436/d/main.rb` など）のスタイルに合わせる（ファイル冒頭にグレード・問題名・解法をコメント）。

利用可能な gem は `Gemfile` に固定: `ac-library-rb`, `numo-narray`, `rbtree`。
自前でデータ構造を書く前に `ac-library-rb` に無いか確認する（`atcoder-ruby` スキル参照）。

## README.md の更新

`README.md` はグレードごとの問題一覧表（問題名 / 出典 / 備考 / 回答リンク）。
問題を解いたら該当行の「備考」に解法、「回答」に `main.rb` への相対リンクを追記する。
これは進捗管理表なので、解答を追加したら合わせて更新すること。
