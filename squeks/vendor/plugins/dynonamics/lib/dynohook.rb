ActionController::Base.class_eval do
  def heroku_info
    return self.request.headers if self.respond_to?(:request) and self.request.respond_to?(:headers)
    return nil
  end
end

puts
puts "================================="
puts "Dynonamics"
puts "http://dynonamics.heroku.com/help"
puts "---------------------------------"
puts "Detect Rails version #{Rails::VERSION::STRING} (Major version=#{Rails::VERSION::STRING[0].chr})"

if Rails::VERSION::STRING.to_s[0].chr=='3'
  
  puts "Load Dynonamics hook for Rails version 3"
  require 'dynohook_rails_3'
  
elsif Rails::VERSION::STRING.to_s[0].chr=='2'
  
  puts "Load Dynonamics hook for Rails version 2"
  require 'dynohook_rails_2'
  
end

puts "================================="
puts