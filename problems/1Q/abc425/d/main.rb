# -
# ABC425/D
# シミュレーション
# 黒化時刻を記録した幅優先探索

def inside?(r, c, h, w)
  0 <= r && r < h && 0 <= c && c < w
end

H, W = gets.split.map(&:to_i)
S = Array.new(H) { gets.chomp.chars }

blacks = []
ans = 0
H.times do |i|
  W.times do |j|
    next if S[i][j] == "."
    S[i][j] = 0
    blacks << [i, j]
    ans += 1
  end
end

until blacks.empty?
  r, c = blacks.shift
  whites = []
  [[r + 1, c], [r, c + 1], [r - 1, c], [r, c - 1]].each do |nr, nc|
    next unless inside?(nr, nc, H, W) && S[nr][nc] == "."
    whites << [nr, nc]
  end

  whites.each do |r1, c1|
    cnt = 0
    [[r1 + 1, c1], [r1, c1 + 1], [r1 - 1, c1], [r1, c1 - 1]].each do |nr, nc|
      next unless inside?(nr, nc, H, W) && S[nr][nc] != "."
      cnt += 1 if S[nr][nc] <= S[r][c]
    end
    next if cnt != 1
    blacks << [r1, c1]
    ans += 1
    S[r1][c1] = S[r][c] + 1
  end
end

puts ans
