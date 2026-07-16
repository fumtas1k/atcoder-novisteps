# 1Q
# ABC426/D
# Pop and Insert
# ランレングス:連続区間の最長
#
# 発想の転換: 何回操作するかではなく「操作せず残す文字」を数える。
# 全て c にするとき、一度も動かさない文字は元の並びで連続していなければ
# ならない(間の文字も動かせなくなるため)。よって残せるのは c の最長連続
# 区間だけで、その長さ M_c を最大化するのが最適。
# コスト内訳(全て c にする場合):
#   ・c でない文字 … 反転して挿入で 1 回ずつ  => (N - C_c)
#   ・残せない c の文字 … 一度どかして戻すので 2 回ずつ => 2*(C_c - M_c)
# c=0,1 両方試して最小を取る。ここで N - C_c は反対の文字数 cnt[1-c]。

gets.to_i.times do
  n = gets.to_i
  ss = gets.chomp.chars.map(&:to_i)

  # 連続区間の最大値
  max = [0] * 2
  cnt = [0] * 2
  l = 0
  while l < n
    r = l + 1
    r += 1 while r < n && ss[l] == ss[r]
    interval = r - l
    cnt[ss[l]] += interval
    max[ss[l]] = [max[ss[l]], interval].max
    l = r
  end
  # 全て1にする場合と全て0にする場合
  puts [cnt[0] + 2 * (cnt[1] - max[1]), cnt[1] + 2 * (cnt[0] - max[0])].min
end