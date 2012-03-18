class PostOwner
  include Mongoid::Document
  
  field :ip_address, :type=>String
  embedded_in :kratoo
  
  ANONYMOUS_TYPE = "OwnerAnonymous"
  PUBLIC_TYPE = "OwnerPublic"
  
  def is_member
    raise 'is_member is not implemented'
  end
  
  def self.create_object(kratoo, member, name, is_anonymous, remote_ip)
    
    if member.is_guest
      
      # We might allow Guest to post in the future, so the below line is kept.
      # return OwnerGuest.new(:username=>name.strip,:ip_address=>remote_ip)
      
      raise PostOwnerException, ({:summary=>WhowishWord.word_for(:kratoo,:do_not_allow_guest)})
      
    else
      
      type = kratoo.get_post_owner_type(member)
      type = (is_anonymous=="yes") ? ANONYMOUS_TYPE : PUBLIC_TYPE if type == ""
      
      if type == ANONYMOUS_TYPE
        
        anonymous_name = kratoo.get_anonymous_name(member)
        
        if anonymous_name == "" and kratoo.is_anonymous_name_used(name)
          raise PostOwnerException, ({:username=>WhowishWord.word_for(:kratoo, :username_redundant)})
        end
        
        anonymous_name = name if anonymous_name == ""
        
        if anonymous_name == ""
          raise PostOwnerException, ({:username=>WhowishWord.word_for(:kratoo, :username_presence)})
        end
        
        return OwnerAnonymous.new(:member_id=>member.id, :ip_address=>remote_ip, :username=>anonymous_name)
        
      elsif type == PUBLIC_TYPE
        
        return OwnerPublic.new(:member_id=>member.id,:ip_address=>remote_ip,:username=>member.username)
        
      else
        raise "Invalid owner type: #{type} is not allowed"
      end
      
      
    end
  end
  
end


