require 'digest/sha2'

h = Digest::SHA2.new << 'string'
puts h.to_s

h2 = Digest::SHA2.new << 'string'
puts h2.to_s

h3 = Digest::SHA2.new << 'booboo'
puts h3.to_s
