class AsyncFacebookCache
  include FacebookHelper
  
  attr_accessor :facebook_id
  attr_accessor :oauth_token
  
  def initialize(the_id,oauth)
    self.facebook_id = the_id
    self.oauth_token = oauth

  end
  
  def perform
    $oauth_token = oauth_token
    
    get_facebook_info(facebook_id,true)
    
  end
  
end