# 1Q
# ABC427/D
# The Simple Game
# ゲーム / 動的計画法

A, B = "AB".bytes

gets.to_i.times do
  n, m, k = gets.split.map(&:to_i)
  ss = gets.chomp.bytes
  edges = Array.new(n) { [] }
  m.times do
    u, v = gets.split.map(&:to_i).map(&:pred)
    edges[u] << v
  end

  # その時の手番が勝つか
  # 初期値として最後の手番が勝つかを入れる
  dp = Array.new(n) { ss[it] == A }
  (2 * k).times do |i|
    dp = n.times.map do |i|
      edges[i].any? { !dp[it] }
    end
  end
  puts dp[0] ? "Alice" : "Bob"
end
