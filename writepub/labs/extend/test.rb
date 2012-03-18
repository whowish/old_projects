module TestModule
  def do_something
    puts "Hello"
  end
  
  extend self
end

TestModule.do_something