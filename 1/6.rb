require 'base64'
require 'byebug'

keysize_lower = 2
keysize_upper = 40
f = File.open("6.txt")
input = Base64.decode64 f.read

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

def hamming_distance_array(a,b)
  return -1 if a.length != b.length
  dist = 0
  a.each_with_index do |a_char, index|
    dist += 1 if a_char != b[index]
  end
  return dist
end

def to_bin(str)
  str.unpack("B*").first
end

search = []
(keysize_lower..keysize_upper).each do |keysize|
  score = 0
  count = 0
  input.each_byte.each_slice(keysize).each_cons(2) do |a, b|
    hd = hamming_distance_array a,b
    score += hd / keysize
    count += 1
  end
  search.push({ keysize: keysize, score: score.to_f / count.to_f })
end

search.sort! { |a,b|
  a[:score] - b[:score]
}
puts "The most likely keysize is #{search.first[:keysize]}"
# puts hamming_distance "this is a test", "wokka wokka!!!"

