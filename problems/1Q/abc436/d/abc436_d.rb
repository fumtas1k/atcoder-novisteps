# Q1
# ABC436/D
# Teleport Maze
# 幅優先探索(BFS)

HASH, DOT = "#.".bytes
H, W = gets.split.map(&:to_i)
S = []
warps = Hash.new {|h, k| h[k] = [] }
H.times do |i|
  row = gets.chomp.bytes
  S << row
  row.each_with_index do |c, j|
    next if c == HASH || c == DOT
    warps[c] << [i, j]
  end
end

visited = Array.new(H) { [false] * W }
visited[0][0] = true
# [r, c, dist]
log = [[0, 0, 0]]
until log.empty?
  r, c, dist = log.shift
  if [r, c] == [H - 1, W - 1]
    puts dist
    exit
  end

  unless S[r][c] == HASH || S[r][c] == DOT
    warps[S[r][c]].each do |nr, nc|
      next if visited[nr][nc]
      visited[nr][nc] = true
      log << [nr, nc, dist + 1]
    end
    warps[S[r][c]].clear
  end

  [[r + 1, c], [r - 1, c], [r, c + 1], [r, c - 1]].each do |nr, nc|
    next unless nr.between?(0, H - 1) && nc.between?(0, W - 1) && S[nr][nc] != HASH && !visited[nr][nc]
    visited[nr][nc] = true
    log << [nr, nc, dist + 1]
  end
end

puts -1
