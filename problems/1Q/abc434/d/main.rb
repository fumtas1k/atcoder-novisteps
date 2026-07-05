# 1Q
# ABC434/D
# 2次元imos+累積和

MAX = 2000
N = gets.to_i
UDLR = Array.new(N) { gets.split.map(&:to_i).map(&:pred) }
clouds = Array.new(MAX + 1) { [0] * (MAX + 1) }
UDLR.each do |u, d, l, r|
  clouds[u][l] += 1
  clouds[u][r + 1] -= 1
  clouds[d + 1][l] -= 1
  clouds[d + 1][r + 1] += 1
end

(MAX + 1).times do |i|
  (MAX + 1).times do |j|
    clouds[i][j] += clouds[i - 1][j] if i > 0
    clouds[i][j] += clouds[i][j - 1] if j > 0
    clouds[i][j] -= clouds[i - 1][j - 1] if i > 0 && j > 0
  end
end

zero = 0
alones = Array.new(MAX + 1) { [0] * (MAX + 1) }
MAX.times do |i|
  MAX.times do |j|
    zero += 1 if clouds[i][j].zero?
    next unless clouds[i][j] == 1
    alones[i + 1][j + 1] = 1
  end
end

(1 .. MAX).each do |i|
  (1 .. MAX).each do |j|
    alones[i][j] += alones[i - 1][j] if i > 0
    alones[i][j] += alones[i][j - 1] if j > 0
    alones[i][j] -= alones[i - 1][j - 1] if i > 0 && j > 0
  end
end

calc = -> (u, d, l, r) do
  alones[d + 1][r + 1] - alones[d + 1][l] - alones[u][r + 1] + alones[u][l]
end

UDLR.each do |udlr|
  puts zero + calc.(*udlr)
end