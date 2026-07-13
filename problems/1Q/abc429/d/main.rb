# 1Q
# ABC429/D
# On AtCoder Conference
# 座標圧縮 + 環状尺取り

N, M, C = gets.split.map(&:to_i)
A = gets.split.map(&:to_i)
tally = A.tally.sort_by(&:first)
n = tally.size

ans = r = sum = 0
n.times do |l|
  while sum < C
    sum += tally[r % n][1]
    r += 1
  end
  gap = (tally[l][0] - tally[l - 1][0]) % M
  gap = M if gap.zero?
  ans += sum * gap
  sum -= tally[l][1]
end

puts ans