# 1Q
# ABC387/C
# Snake Numbers
# 桁ごとの数え上げ（桁DP）
# スネーク数(>=10): 先頭桁がそれ以外の全桁より真に大きい整数

# f(x) = [10, x] に含まれるスネーク数の個数
def f(x)
  return 0 if x < 10
  digs = x.digits.reverse
  n = digs.size
  ans = 0
  # 桁数が n 未満 (2..n-1): 先頭 top(1..9), 残り d-1 桁は 0..top-1 で自由 -> top^(d-1)
  (2...n).each do |d|
    (1..9).each { |top| ans += top**(d - 1) }
  end
  # ちょうど n 桁で x 以下のスネーク数（先頭桁を top とする）
  (1..digs[0]).each do |top|
    if top < digs[0]
      ans += top**(n - 1)
    else
      # top == digs[0]: x にタイトに沿って数える。以降の桁は全て < top 必須
      tight = true
      (1...n).each do |i|
        di = digs[i]
        ans += [di, top].min * top**(n - 1 - i)
        break tight = false if di >= top
      end
      ans += 1 if tight
    end
  end
  ans
end

L, R = gets.split.map(&:to_i)
puts f(R) - f(L - 1)
