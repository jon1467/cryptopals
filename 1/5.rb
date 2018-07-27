require 'byebug'
input = ARGV.shift || "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
key = ARGV.shift || "ICE"

def xor(str, i)
  xored = []
  str.split('').each_byte do |byte, index|
    xored.push((byte ^ i).chr)
  end
  return xored.join
end

def encrypt(str, key)
  str_arr = str.split ''
  key_arr = key.split ''

  key_index = 0
  str_arr.map! do |char|
    out = (char.bytes.first ^ key_arr[key_index%key_arr.length].bytes.first).chr
    key_index += 1
    out
  end

  return str_arr.join
end

def to_hex(str)
  str.unpack('H*').first
end

def to_bin(hex)
  [hex].pack('H*')
end

puts to_hex encrypt(input, key)
