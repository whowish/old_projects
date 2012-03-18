class A
  
  @a = "yes"
  
  def self.hello
    return @a
  end
  
end

class B < A
  
end

puts B.hello