# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include FacebookHelper
  include Foundation
  include ThumbnailismHelper
  
  def get_member_info(facebook_id)
    member = Member.first(:conditions=>{:facebook_id=>facebook_id})
    
    member.set_facebook_cache(get_facebook_info(member.facebook_id))

    member
  end
  
   def get_thai_date(date)
     result = date.strftime("%d")
     month = ["มกราคม","กุมภาพันธ์","มีนาคม","เมษายน","พฤษภาคม","มิถุนายน","กรกฎาคม","สิงหาคม","กันยายน","ตุลาคม","พฤศจิกายน","ธันวาคม"]
     result += " " + month[date.month-1] 
     result += " " + (date.year + 543).to_i.to_s
     return result
   end
  
  def http_post(url,data={},retry_max=1)

      logger.debug { "Enter http_post()" }
      logger.debug {"url=#{url}"}
      
      require 'cgi'
      nvp = "dummy="
      data.each_pair { |key, value| 
        nvp += "&#{key}=#{CGI.escape(value.to_s)}"
      }
      
      logger.debug {"data=#{nvp[0..100]}"}

      require 'net/http'
      require 'net/https'
      require 'uri'
      
      Net::HTTP.version_1_2
      
      url = URI.parse(url)
  
      http = Net::HTTP.new(url.host,url.port)
#      http.use_ssl = true
#      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      response = nil
      
      retry_count = 0
      while retry_count < retry_max
        begin
          response = http.post(url.path,nvp)
          break
        rescue Exception=>e
          logger.debug { "Error: #{e}"}
          retry_count = retry_count + 1
        end
      end
      
      if response
        logger.debug {"Exit http_post() with response.body=#{response.body[0..100]}"}
        return response.body
      else
        logger.debug {"Exit http_post() with failure (retry=#{retry_count}"}
        raise "HTTP connection to #{url} failed" 
      end
  end

end
