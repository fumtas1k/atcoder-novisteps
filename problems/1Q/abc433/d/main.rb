# 1Q
# ABC433/D
# 183183
# 桁DP / 剰余カウント

MAX_DIGITS = 10
N, M = gets.split.map(&:to_i)
A = gets.split.map(&:to_i)

# dp[i][j] := i桁下駄上げした時にMで割った余りjの個数
dp = Array.new(MAX_DIGITS + 1) { Hash.new(0) }
mods = []
A.each do |a|
  mod = a % M
  d = a.to_s.size
  mods << [mod, d]
  (MAX_DIGITS + 1).times do |i|
    dp[i][mod * 10.pow(i, M) % M] += 1
  end
end

ans = 0
mods.each do |mod, d|
  ans += dp[d][(M - mod) % M]
end

puts ans