class AsyncFacebookMethod
  include FacebookHelper
  
  attr_accessor :action
  attr_accessor :facebook_id
  attr_accessor :data
  attr_accessor :oauth_token
  
  def initialize(action,facebook_id,data,oauth_token)
    self.action = action
    self.facebook_id = facebook_id
    self.data = data
    self.oauth_token = oauth_token
  end
  
  def perform
    $oauth_token = oauth_token
    post_data(action,data,facebook_id)
  end
end