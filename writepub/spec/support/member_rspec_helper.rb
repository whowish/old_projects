# encoding: utf-8
require 'bcrypt'

module MemberRspecHelper
  
  def mock_member(username,password,facebook_id=nil)
    return Member.create(:username=>username,
                          :password=>BCrypt::Password.create(password).to_s,
                          :facebook_id=>facebook_id)
  end
  
  def mock_member_session(member)
    return {
            :member_id=>member.id,
            :member_signature=>Member.generate_cookies_signature(member.id,member.cookies_salt)
           }  
  end
end