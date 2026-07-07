# AtCoder 用のシェルヘルパー。post-create.sh が ~/.bashrc から source する。
# ローカル(zsh)の atcr / rtest / ropen を devcontainer(bash)向けに移植したもの。

# ropen: カレントの問題ディレクトリの解答ファイルを VS Code で開く。
ropen() {
  code main.rb
}

# atcr <contest> <problem>: 問題をセットアップして開く。
#   acc new でコンテストを取得 → <contest>/<problem> へ移動 → main.rb を開く。
#   NODE_OPTIONS は Node v24 の DEP0040(punycode) 警告を抑止する。
atcr() {
  NODE_OPTIONS="--disable-warning=DEP0040" acc new "$1" && pushd "$1/$2" && ropen
}

# rtest: カレントの main.rb を tests/ のサンプルで実行(-N は末尾改行差を無視)。
#   alias ではなく関数にする(alias は非対話シェルで展開されず環境依存になるため)。
#   gem はグローバル導入(atcoder-ruby feature)なので bundle exec は不要。
rtest() {
  oj t -c "ruby main.rb" -d tests -N
}
