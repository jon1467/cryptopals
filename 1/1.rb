require 'base64'

args = ARGV.empty? ? ["49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d"] : ARGV

args.each do |arg|
  out = [arg].pack("H*")
  puts Base64.encode64(out)
end
