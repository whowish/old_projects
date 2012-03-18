class FacebookCache < ActiveRecord::Base
  include FacebookHelper
  
  ERROR_NO_PERMISSION = "No permission"
  ERROR_INVALID_OAUTH = "Invalid OAuth token"
  ERROR_OTHER = "Other error"

  SCOPE_EMAIL = "email"
  SCOPE_PUBLISH_STREAM = "publish_stream"
  SCOPE_EDUCATION_HISTORY = "education_history"
  
  attr_accessor :oauth_token,:expires,:profile_id,:country,:locale
  
  def self.get_guest
    return  new(:facebook_id=>0,:name=>"Guest")
  end
  
  def is_guest
    return (facebook_id == nil or facebook_id == 0)
  end
  
  def parse_error(response_obj)
    return nil if !response_obj['error']
    
    if response_obj['error']['type'] == "OAuthException"
      if response_obj['error']['message'].match('#200') \
          or response_obj['error']['message'].match('Error validating access token.')#"(#341) Feed action request limit reached"
        
        return {:error_id=>ERROR_NO_PERMISSION,:error_message=>response_obj['error']['message']}
      else
        return {:error_id=>ERROR_OTHER,:error_message=>response_obj['error']['message']}
      end
    else
      return {:error_id=>ERROR_OTHER,:error_message=>response_obj['error']['message']}
    end
  end
 
  def set_as_current_user(hash_obj)
    @oauth_token = hash_obj['oauth_token']
    @expires = hash_obj['expires']
    @profile_id = hash_obj['profile_id']
    @country = hash_obj['user']['country']
    @locale = hash_obj['user']['locale']
    
    all_friends
  end
  
  def home_url
    
    if is_guest
      return '/home'
    else
      return '/home?user_id='+facebook_id.to_s
    end
    
  end
  
  def profile_url
    if is_guest
      return '#'
    else
      return 'http://www.facebook.com/profile.php?id='+facebook_id.to_s
    end
  end
  
  def get_badge(color='')
    style_color = 'style="color: '+color+' !important;"'
    
    if is_guest
      return '<span '+style_color+'>'+name+'</span>'
    else
      return '<a href="'+profile_url+'" target="_new_<%=user.facebook_id.to_s%>" title="Go to '+get_possessive_adj(self).downcase+' facebook"><span class="facebook_profile_link"></span></a> <a '+style_color+' href="'+home_url+'"  title="Go to '+get_possessive_adj(self).downcase+' home page">'+name+'</a>'
    end
    
  end
  
  def profile_picture_url(type="square")
    if is_guest
      if type == "square"
        return "/whowish_foundation_asset/facebook_blank_profile.jpg"
      else
        return "/whowish_foundation_asset/facebook_blank_profile_big.jpg"
      end
    else
      return "http://graph.facebook.com/"+facebook_id.to_s+"/picture?type="+type
    end
    
  end
  
  def all_friends
    return [] if is_guest
    get_friends(facebook_id)
  end
  
  def all_friends_of_friends
    return [] if is_guest
    get_friends_of_friends(facebook_id)
  end
  
end