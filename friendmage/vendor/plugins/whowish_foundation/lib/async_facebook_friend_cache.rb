class AsyncFacebookFriendCache
  include FacebookHelper
  
  attr_accessor :facebook_id
  attr_accessor :oauth_token
  
  def initialize(the_id,oauth)
    self.facebook_id = the_id
    self.oauth_token = oauth
  end
  
  def perform
    $oauth_token = self.oauth_token
    
    get_friends(facebook_id,true)
    
  end
  
end