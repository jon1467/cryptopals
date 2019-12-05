arg1 = ARGV.shift || "1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736"
heuristic = "ETAOIN SHRDLU".downcase.split ''

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

hex = [arg1].pack('H*') # pack _into_ binary

hexors = []
(0..255).each do |cipher|
  hexors.push(xor_array_on_single_value(hex, cipher))
end

processed_hexors = []
hexors.each do |hexor|
  chars = hexor.split ''
  freq = {}
  chars.each do |char|
    freq[char] == nil ? freq[char] = 1 : freq[char] += 1
  end
  freq[:text] = hexor
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

puts "1st: (#{processed_hexors.first[:score]}) #{processed_hexors.first[:text]}"
puts "2nd: (#{processed_hexors[1][:score]}) #{processed_hexors[1][:text]}"
puts "3rd: (#{processed_hexors[2][:score]}) #{processed_hexors[2][:text]}"
