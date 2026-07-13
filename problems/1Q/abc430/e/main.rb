# 1Q
# ABC430/E
# Shift String
# Z algorithm

# require "ac-library-rb/z_algorithm"
# include AcLibraryRb

def z_algorithm(str)
  bytes = str.bytes
  n = str.size
  length = [0] * n
  length[0] = n
  i = 1
  len = 0
  while i < n
    len += 1 while i + len < n && bytes[len] == bytes[i + len]
    length[i] = len

    next i += 1 if len.zero?

    j = 1
    while i + j < n && j + length[j] < len
      length[i + j] = length[j]
      j += 1
    end
    i += j
    len -= j
  end
  length
end
gets.to_i.times do
  as = gets.chomp
  bs = gets.chomp
  n = as.size
  res = z_algorithm(bs + "$" + as * 2)
  ans = -1
  (2 * n).times do |i|
    break ans = i if res[n + 1 + i] == n
  end
  puts ans
end
