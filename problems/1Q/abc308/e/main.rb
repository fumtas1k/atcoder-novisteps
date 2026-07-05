# Q1
# ABC308/E
# MEX
# 累積和
# 真ん中決め打ち

MEX = "MEX".bytes
mexes = Hash.new(0)
[*0 ... 3].repeated_permutation(3) do |a, b, c|
  4.times do |i|
    if [a, b, c].all? { _1 != i }
      break mexes[[a, b, c]] = i
    end
  end
end

N = gets.to_i
A = gets.split.map(&:to_i)
S = gets.chomp.bytes
ms = Array.new(N + 1) { [0] * 3 }
xs = Array.new(N + 1) { [0] * 3 }
N.times do |i|
  3.times do |j|
    ms[i + 1][j] = ms[i][j]
    xs[i + 1][j] = xs[i][j]
  end
  case S[i]
  when MEX[0]
    ms[i + 1][A[i]] += 1
  when MEX[2]
    xs[i + 1][A[i]] += 1
  end
end

# 真ん中決め打ち
ans = 0
N.times do |idx|
  next if S[idx] != MEX[1]
  j = A[idx]
  3.times do |i|
    3.times do |k|
      ans += mexes[[i, j, k]] * ms[idx][i] * (xs[N][k] - xs[idx + 1][k])
    end
  end
end

puts ans
