require 'base64'

arg1 = ARGV.shift || "1c0111001f010100061a024b53535009181c"
arg2 = ARGV.shift || "686974207468652062756c6c277320657965"

def hex_array(input)
  hex_arr = []
  input.each_char do |char|
    hex_arr.push(char.hex)
  end
  hex_arr
end

hex1 = hex_array arg1
hex2 = hex_array arg2

if hex1.length == hex2.length
  xored = []
  hex1.each_with_index do |elem1, index|
    xored.push((elem1 ^ hex2[index]).to_s(16))
  end
  puts xored.join
end

# puts Base64.encode64(hex)
