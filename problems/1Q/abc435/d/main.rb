# 1Q
# ABC435/D
# Reachability Query 2
# グラフ / 逆辺伝播

N, M = gets.split.map(&:to_i)
rev_edges = Array.new(N) { [] }
M.times do
  x, y = gets.split.map(&:to_i).map(&:pred)
  rev_edges[y] << x
end

is_black = [false] * N
# 再帰DFSだと深くなりすぎるので明示スタックの反復DFSにした
mark = -> start do
  return if is_black[start]
  is_black[start] = true
  stack = [start]
  until stack.empty?
    pos = stack.pop
    rev_edges[pos].each do |nxt|
      next if is_black[nxt]
      is_black[nxt] = true
      stack << nxt
    end
  end
end

gets.to_i.times do
  t, v = gets.split.map(&:to_i)
  v -= 1
  case t
  when 1
    mark.(v)
  when 2
    puts is_black[v] ? "Yes" : "No"
  end
end