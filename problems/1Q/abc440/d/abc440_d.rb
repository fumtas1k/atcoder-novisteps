# 1Q
# ABC440/D
# Forbidden List 2

INF = 1 << 60
def bsearch(ng, ok, &block)
  while (ok - ng).abs > 1
    mid = (ok + ng) / 2
    block[mid] ? ok = mid : ng = mid
  end
  ok
end

N, Q = gets.split.map(&:to_i)
# 最後に番兵を置いておく
A = gets.split.map(&:to_i).sort << INF

ans = []
Q.times do
  x, y = gets.split.map(&:to_i)
  s = A.bsearch_index { _1 >= x } - 1
  # y番目以下の最大のAのindexを求める:
  t = bsearch(s, N) { (A[_1] - x + 1) - (_1 - s) >= y }
  # x以上y番目までには、A[s], A[s + 1] .. A[t - 1]が含まれている
  ans << x + y - 1 + (t - 1 - s)
end

puts ans
