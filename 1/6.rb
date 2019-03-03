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

def to_slices(str, len)
  str.chars.each_slice(len).map(&:join)
end

def transpose_block(block)
  length = block[0].length - 1
  new_block = []
  (0..length).each do |index|
    new_block[index] = []
  end

  block.each do |slice|
    chars = slice.split ''
    chars.each_with_index do |char, index|
      new_block[index].push char
    end
  end

  return new_block
end

def hex_array(input)
  hex_arr = []
  input.each_char do |char|
    hex_arr.push(char.hex)
  end
  hex_arr
end

def xor_array_on_single_value(array, i)
  xored = []
  array.each_byte do |byte, index|
    xored.push((byte ^ i).chr)
  end
  return xored.join
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

most_likely = [search[0][:keysize]]
puts "Most likely keysizes (desc): #{most_likely.join ', '}"

block_sets = most_likely.each_with_object([]) do |keysize, arr|
  arr.push to_slices(input, keysize)
end

block_sets.map! { |block| transpose_block block }

heuristic = "ETAOIN SHRDLU".downcase.split ''


key_set = []
block_sets.each do |block_set|
  key = []
  block_set.each do |slice|

    hexors = []
    (0..255).each do |cipher|
      hexors.push({ cipher: cipher, hexor: xor_array_on_single_value(slice.join, cipher) })
    end

    processed_hexors = []
    hexors.each do |hexor_obj|
      hexor = hexor_obj[:hexor]
      chars = hexor.split ''
      freq = {}
      chars.each do |char|
        freq[char] == nil ? freq[char] = 1 : freq[char] += 1
      end
      freq[:text] = hexor
      freq[:cipher] = hexor_obj[:cipher]
      processed_hexors.push freq
    end

    processed_hexors.sort! do |a,b|
      a_score = 0
      b_score = 0

      allowed_chars = /\w|\s|'/

      heuristic.each_with_index do |char, next_i|
        char_next = heuristic[next_i+1]
        last = char_next.nil?
        a[char] = 0 if a[char].nil?
        b[char] = 0 if b[char].nil?
        a[char_next] = 0 if a[char_next].nil?
        b[char_next] = 0 if b[char_next].nil?
        unless last
          a_score += 1 if a[char] > a[char_next]
          b_score += 1 if b[char] > b[char_next]
        end
      end

      # check for english chars
      a[:text].split("").each do |a_char|
        a_score -= 12 unless a_char =~ allowed_chars
      end
      b[:text].split("").each do |b_char|
        b_score -= 12 unless b_char =~ allowed_chars
      end

      a[:score] = a_score
      b[:score] = b_score
      b_score - a_score
    end
    key.push processed_hexors.first[:cipher]
  end
  key_set.push key
end
likely_key = key_set[0]
puts likely_key.map { |x| x.chr }.join


key = key_set[0]
deciphered = input.each_byte.each_with_index.map do |byte, index|
  (byte ^ likely_key[index % likely_key.length].to_i).chr
end.join

puts deciphered
# TODO why THB?? Check possibilities for that letter
