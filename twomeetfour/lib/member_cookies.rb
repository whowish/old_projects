require 'digest/sha2'

module MemberCookies
  
  
  def self.included(base)
    base.extend(ClassMethods)
    
    base.field :cookies_salt, :type=>String
    
    base.before_create do |record|
      record.cookies_salt = (Digest::SHA2.new << "#{rand()}").to_s
    end
    
  end
  
  
  def save_cookies(session,cookies,remember_me=false)
    session[:member_id] = self.id
    
    if remember_me
      cookies.permanent.signed[:member_id] = self.id
    else
      cookies.permanent.signed[:member_id] = ""
    end
    
    signature = self.class.generate_cookies_signature(self.id,self.cookies_salt)
    
    session[:member_signature] = signature
    cookies.permanent.signed[:member_signature] = signature
  end
  
  
  module ClassMethods


    def clear_cookies(session,cookies)
      session[:member_id] = ""
      session[:member_signature] = ""
      
      cookies.permanent.signed[:member_id] = ""
      cookies.permanent.signed[:member_signature] = ""
    end
    
    
    def generate_cookies_signature(member_id,salt)
      signature = (Digest::SHA2.new << "#{member_id} #{salt}").to_s
      return signature
    end
    
    
    def is_credential_ok(member,signature)
      return signature == generate_cookies_signature(member.id,member.cookies_salt)
    end
    
    
    def get_member_from_cookies(session,cookies)
      
      if cookies.signed[:member_id] != nil \
         and cookies.signed[:member_id] != ""
         
        session[:member_id] = cookies.signed[:member_id]
        session[:member_signature] = cookies.signed[:member_signature]
        
      end
      
      member = Member.first(:conditions=>{:id=>session[:member_id]})
      raise "No member" if !member
      
      raise "Signature invalid" if !is_credential_ok(member,session[:member_signature])
      
      return member
      
    rescue Exception=>e
      self.clear_cookies(session,cookies)
      return self.get_guest
    end
    
    
  end
  
end