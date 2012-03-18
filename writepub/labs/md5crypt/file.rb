# encoding: utf-8

require 'crypt3'

puts Crypt3.check('263873', '$1$KppM68a2$1xxdZ2wKfFeYwHCYFA3B80')

puts Crypt3.crypt('263873')
puts Crypt3.crypt('263873')
puts Crypt3.crypt('263873')