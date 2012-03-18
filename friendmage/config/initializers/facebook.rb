class FacebookCache
  include ThumbnailismHelper
  
  def after_initialize

  end

  def home_url
    return '/profile?user_id='+facebook_id
  end
  
  
end