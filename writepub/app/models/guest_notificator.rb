class GuestNotificator < Notificator
  field :username, :type=>String
  
  def is_member
    return false
  end
end
