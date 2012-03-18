class User

  def initialize

  end
  
  def is_guest
    raise "is_guest() is not implemented for #{self.class}"
  end
  
  def is_member
    return !self.is_guest
  end
  
end