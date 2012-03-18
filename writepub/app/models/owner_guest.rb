class OwnerGuest < PostOwner

  field :username, :type=>String
  
  def is_member
    return false
  end
  
  def get_badge
    return username
  end
  
end