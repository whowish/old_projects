module Facebook
  
  def generate_facebook_connect_url(app_id, url)
    return "https://www.facebook.com/dialog/oauth?client_id=#{app_id}&redirect_uri=#{CGI.escape(url)}"
  end
  
  def set_facebook(facebook)
    $facebook = facebook
    session[:facebook_oauth_token] = $facebook.oauth_token
  end
  
  def connect(code, redirect_url, url_from_facebook="", params={})
    
    facebook = FacebookUser.new
    
    # Get oauth token
    # retry 3 times
    3.times do
      
      log = FacebookLog.new
      log.redirect_url = redirect_url
      log.code = code
      log.url_from_facebook = url_from_facebook
      log.params_from_facebook = params.inspect
      
      begin
  
        url = "https://graph.facebook.com/oauth/access_token"
        q = "?client_id=#{APP_ID}&redirect_uri=#{CGI.escape(redirect_url)}&client_secret=#{APP_SECRET}&code=#{CGI.escape(code)}"
  
        url = URI.parse(url)
        
        log.url = "#{url.path}#{q}"
  
        require 'net/http'
        require 'net/https'

        http = Net::HTTP.new(url.host,url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        http.read_timeout = 60
  
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
        Rails.logger.error { e.to_s_with_trace }
        
        facebook.oauth_token = nil
        
      end
      
      log.save if log.error != nil and log.error != ""
      
      Rails.logger.debug { "oauth=#{facebook.oauth_token}" }
      
      break if facebook.oauth_token != nil
    end
    
    return nil if facebook.oauth_token == nil


    facebook.get_basic_info
    
    return nil if facebook.facebook_id == nil
    
    return facebook
  end
  
  extend self
  
end
