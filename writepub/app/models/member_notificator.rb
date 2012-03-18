class MemberNotificator < Notificator
  field :member_id, :type=>String
  
  def is_member
    return true
  end
end