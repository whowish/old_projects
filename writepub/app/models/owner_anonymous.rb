class OwnerAnonymous < OwnerMember

  field :username, :type=>String
  
   def get_badge
   
    return username
    
  end
  
end