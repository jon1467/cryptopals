require 'byebug'
@heuristic = "ETAOIN SHRDLU".downcase.split ''
@allowed_chars = /\w|\s|'/

def xor_array_on_single_value(array, i)
  xored = []
  array.each_byte do |byte, index|
    xored.push((byte ^ i).chr)
  end
  return xored.join
end

def xor_all(string)
  hex = [string].pack('H*') # pack _into_ binary

  hexors = []
  (0..255).each do |cipher|
    hexors.push(xor_array_on_single_value(hex, cipher))
  end
  return hexors
end

def generate_frequency(hexor)
  chars = hexor.split ''
  freq = {}
  chars.each do |char|
    freq[char] == nil ? freq[char] = 1 : freq[char] += 1
  end
  freq[:text] = hexor
  return freq
end

def generate_frequencies(hexors)
  processed_hexors = []
  hexors.each do |hexor|
    processed_hexors.push generate_frequency(hexor)
  end
  return processed_hexors
end

def sort_hexor(a,b)
  a_score = 0
  b_score = 0

  @heuristic.each_with_index do |char, next_i|
    char_next = @heuristic[next_i+1]
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
    a_score -= 12 unless a_char =~ @allowed_chars
  end
  b[:text].split("").each do |b_char|
    b_score -= 12 unless b_char =~ @allowed_chars
  end

  a[:score] = a_score
  b[:score] = b_score
  return b_score - a_score
end

def process_string(str)
  hexors = xor_all(str)
  return generate_frequencies hexors
end

f = File.open("4.txt")
strs = f.readlines
strs.map! { |str| str[0..str.length-2] } # remove \n

processed_hexors = []
strs.each do |str|
  puts "processing #{str}"
  processed_hexors.push (process_string(str).sort! { |a,b| sort_hexor a, b }).first
end
puts 'sorting'
processed_hexors.sort! { |a,b| sort_hexor a, b }

puts "1st: (#{processed_hexors.first[:score]}) #{processed_hexors.first[:text]}"
puts "2nd: (#{processed_hexors[1][:score]}) #{processed_hexors[1][:text]}"
puts "3rd: (#{processed_hexors[2][:score]}) #{processed_hexors[2][:text]}"
