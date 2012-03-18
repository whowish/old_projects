class Guest < User
  
  def is_guest
    return true
  end
  
  def id
    return false
  end
  
  def is_admin
    return false
  end
  
  def name
    return "Guest"
  end
  
  
  def url
    "javascript:alert('this is a guest');"
  end
  
end