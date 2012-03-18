class OwnerPublic < OwnerMember

  
  field :username, :type=>String
  
  def get_badge
    return  Member.first(:conditions=>{:id=>member_id}).get_badge
  end
  
end