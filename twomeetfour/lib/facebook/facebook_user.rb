class FacebookUser
  
  attr_accessor :facebook_id, :oauth_token, :name
  
  def self.get_facebook_user(oauth_token)
    user = FacebookUser.new
    user.oauth_token = oauth_token
    
    user.get_basic_info
    
    return nil if user.facebook_id == nil
    return user
  end
  
  def get_basic_info
    
    @facebook_id = nil
    @name = nil
    
    data = query_data("SELECT uid, name FROM user WHERE uid = me()")
    
    return if data == nil or !data.instance_of?(Array)
    
    Rails.logger.debug { data.inspect }

    @facebook_id = data[0]['uid']
    @name = data[0]['name']
  end
  
  
  
  def get_friend_count
    data = query_data("SELECT uid2 FROM friend WHERE uid1 = me()")
    
    raise "get friend error" if data == nil or !data.instance_of?(Array)
    
    return data.length
  end

  def query_data(fql)
    
    data = nil
    
    # retry 3 times
    3.times do
      log = FacebookLog.new
      
      begin
        
        url = URI.parse("https://api.facebook.com/method/fql.query")
        
        require 'net/https'

        http = Net::HTTP.new(url.host,url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout = 10
        
        q = "?access_token=#{self.oauth_token}&query=#{CGI.escape(fql)}&format=json"
        
        log.url = url.path+q
        
        response = http.get(url.path+q)
        
        if response.instance_of?(Net::HTTPOK)
          log.response = "OK"
          log.response_body = response.body
          
          data = ActiveSupport::JSON.decode(response.body)
          
        else
          log.error = "Received #{response}"
          log.response_body = response.body
          data = nil
        end
        
        
      rescue Exception=>e
        log.error = e.to_s_with_trace
        Rails.logger.error { e.to_s_with_trace }
        data = nil
      end
      
      log.save if log.error != nil and log.error != ""
      
      break if data != nil
      
    end
    
    return data
    
  end
  
end