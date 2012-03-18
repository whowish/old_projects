class B
  def hello
    A.test
  end
end

class A
  
  def self.test
    puts caller
    puts binding.eval('caller')
  end
end

B.new.hello