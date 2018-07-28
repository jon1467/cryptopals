def hamming_distance(a,b)
  return -1 if a.length != b.length
  dist = 0
  a = to_bin(a).split ''
  b = to_bin(b).split ''
  a.each_with_index do |a_char, index|
    dist += 1 if a_char != b[index]
  end
  return dist
end

def to_bin(str)
  str.unpack("B*").first
end

puts hamming_distance "this is a test", "wokka wokka!!!"
