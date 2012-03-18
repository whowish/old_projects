module FacebookRegistrationHelper
  
  def set_facebook(facebook)
    $facebook = facebook
    session[:facebook_oauth_token] = $facebook.oauth_token
  end
  
  def facebook_connect(code,redirect_url)
    
    facebook = FacebookUser.new
    
    # Get oauth token
    # retry 3 times
    3.times do
      
      log = FacebookLog.new
      
      begin
  
        url = "https://graph.facebook.com/oauth/access_token"
        q = "?client_id=" + APP_ID + "&redirect_uri="+CGI.escape(redirect_url)+"&client_secret=" + APP_SECRET \
            + "&code=" + CGI.escape(code)
  
        url = URI.parse(url)
        
        log.url = "#{url.path}#{q}"
  
        require 'net/http'
        require 'net/https'

        http = Net::HTTP.new(url.host,url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout = 10
  
        response = http.get(url.path+q)
        
        if response.instance_of?(Net::HTTPOK)
          
          log.response = "OK"
          
          log.response_body = response.body
          
          facebook.oauth_token = CGI.parse(response.body)['access_token'][0]
          
        else
          log.error = "Received #{response}"
          log.response_body = response.body
          
          facebook.oauth_token = nil
        end
        
      rescue Exception=>e
        log.error = e.to_s_with_trace
        Rails.logger.debug { e.to_s_with_trace }
        
        facebook.oauth_token = nil
      end
      
      log.save
      
      Rails.logger.debug { "oauth=#{facebook.oauth_token}" }
      
      break if facebook.oauth_token != nil
    end
    
    return nil if facebook.oauth_token == nil


    facebook.get_basic_info
    
    return nil if facebook.facebook_id == nil
    
    return facebook
  end
  
end
