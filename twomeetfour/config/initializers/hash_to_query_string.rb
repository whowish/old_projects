class Hash
  
  def to_query_string

    query_string_pairs = []
    
    self.each_pair do |key, value|
      query_string_pairs.push("#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}")
    end
    
    return query_string_pairs.join("&")

  end
  
end