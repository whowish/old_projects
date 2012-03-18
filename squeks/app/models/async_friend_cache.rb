class AsyncFriendCache
 include FacebookHelper
  
  attr_accessor :facebook_id,
                :crypto_id,
                :oauth_token
  
  def initialize(facebook_id,crypto_id,oauth)
    self.facebook_id = facebook_id
    self.crypto_id = crypto_id
    self.oauth_token = oauth
  end
  
  def perform
    $oauth_token = self.oauth_token
    
    get_friends(facebook_id,crypto_id,true)
    
  end
end