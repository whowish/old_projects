class Notificator
  include Mongoid::Document 
  
  embedded_in :notificator, :polymorphic => true
  
  def is_member
    raise 'is_member is not implemented'
  end
  
  def is_not_member
    return !is_member
  end
  
  def self.build(post_owner)
    
    if post_owner.instance_of?(OwnerGuest)
      return GuestNotificator.new(:username=>post_owner.username)
    elsif post_owner.instance_of?(OwnerAnonymous)
      return AnonymousMemberNotificator.new(:username=>post_owner.username,:member_id=>post_owner.member_id)
    elsif post_owner.instance_of?(OwnerPublic)
      return PublicMemberNotificator.new(:username=>post_owner.username,:member_id=>post_owner.member_id)
    else
      raise "Unknown PostOwner type"
    end
    
  end
  
end







