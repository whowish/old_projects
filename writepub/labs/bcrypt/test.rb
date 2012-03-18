require 'bcrypt'

x = BCrypt::Password.create("my password")
puts x.to_s
puts x.salt
puts x == "my password"
