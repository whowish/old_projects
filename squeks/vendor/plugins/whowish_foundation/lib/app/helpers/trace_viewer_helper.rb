module TraceViewerHelper
  
  
  
  def locateIp(ip,only_country=false)
    
    return "US"
    
    begin
      ips = ip.to_s
      #ips = "113.53.155.213"
      
      @ip_to_country ||= {}
      @ip_to_code ||= {}
      
      return @ip_to_code[ips] if only_country and @ip_to_code[ips]
      return @ip_to_country[ips] if !only_country and @ip_to_country[ips] 
      
      api = "ip_query"
      api = "ip_query_country" if only_country
   
      require 'net/http'
      require 'net/https'
      require 'uri'
      
      Net::HTTP.version_1_2
      
      url = URI.parse("http://api.ipinfodb.com/v2/"+api+".php")
  
      http = Net::HTTP.new(url.host,url.port)
      http.read_timeout = 6
      response = http.get(url.path+"?key=7b79f4271a58ffa4c9056e933ce02f913ca2b52e397001888deeffe51ee35a5a&ip="+ips+"&timezone=false&output=json")
  
      data = response.body
      
      print data
      
      #print data
      #print xml_data
      require 'json'
      data = JSON.parse data
      
      @ip_to_code[ips] = data['CountryCode']
      
      return data['CountryCode'] if only_country
      
      @ip_to_country[ips] = data['City']+", "+data['RegionName']+", "+data['CountryName']
      return data['City']+", "+data['RegionName']+", "+data['CountryName']
    rescue Exception=>e
      puts "#{e.to_s_with_trace}"
      return "US" if only_country
      return "Error, US" if !only_country
    end
  end  #end of method locateIp

end
