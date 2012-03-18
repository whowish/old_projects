module AmazonHelper
  
  def find_item_amazon_by_keyword(keyword,number_of_product)
    require 'cgi'
    require 'base64'
    url = "http://webservices.amazon.com/onca/xml"
    
    get_params = {:Service=>"AWSECommerceService",
                  :Operation=>"ItemSearch",
                  :AWSAccessKeyId=>"AKIAIUNNIYYW4U3DHNVQ",
                  :Timestamp=>Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
                  :Version=>"2010-11-01"}
    
    # add some more parameters
    get_params[:Keywords] = keyword
    get_params[:SearchIndex] = "All"
    get_params[:ResponseGroup] = "Medium,Images"

    get_params = get_params.to_a.map {|a| a[0].to_s+"="+CGI.escape(a[1])}.sort {|x,y| x <=> y }.join('&')

    #print get_params+"\n\n"

    #generate signature
    require 'openssl'
    
    #print url+"?"+get_params+"\n\n";
    
    data = "GET\n" + 
           "webservices.amazon.com\n" + 
           "/onca/xml\n" + get_params
           
    #print data+"\n\n"
    
    sig = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha256'),"lHfx9QtH8QS1EPxZNXE10DLzQBZ+xcZfZpr5YQ/K", data).to_s).strip

    get_params = get_params + "&Signature="+CGI.escape(sig)
    
    print url+"?"+get_params+"\n\n";
    require 'restclient'
    
    products = []
    
    begin
      response_body = RestClient.get(url+"?"+get_params)
  
      
      require 'rexml/document'
      doc = REXML::Document.new(response_body)
      
      
      doc.elements.each("*/Items/Item") { |e|
        
      
        p = AmazonProduct.new
        p.url = e.elements["DetailPageURL"].text
        p.image_url = e.elements["SmallImage/URL"].text
        p.title = e.elements["ItemAttributes/Title"].text
        p.group = (e.elements["ItemAttributes/ProductGroup"].text rescue nil)
        p.price = (e.elements["ItemAttributes/ListPrice/FormattedPrice"].text rescue \
                    (e.elements["OfferSummary/LowestUsedPrice/FormattedPrice"].text rescue \
                      (e.elements["OfferSummary/LowestRefurbishedPrice/FormattedPrice"].text rescue nil) \
                     ) \
                   )
      
        products.push(p)
        
        break if products.length >= number_of_product
      }
    rescue
    
    end
    
    
    return products

  end

  def get_pp_xml(elems,prefix="")
    return "" if !elems
    indent = "&nbsp;"*10
    str = ""
    
    elems.each { |e|
      str += prefix+"&lt;"+e.name+"&gt;<br/>"
      str += indent+prefix+e.text+"<br/>" if e.text
      str += get_pp_xml(e.elements.to_a,indent+prefix)
      str += prefix+"&lt;/"+e.name+"&gt;<br/>"
    }
    
    return str
  end
end