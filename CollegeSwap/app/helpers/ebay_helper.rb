module EbayHelper
  
  def find_item_by_keyword(keyword,number_of_product)
    require 'net/http'
    require 'net/https'
    require 'uri'
    require 'cgi'
    
    Net::HTTP.version_1_2
   
    cgi_keyword = CGI.escape(keyword)

    headers = {}
    
    url = URI.parse('http://svcs.ebay.com/services/search/FindingService/v1')
    
    data = "?OPERATION-NAME=findItemsByKeywords"
    data += "&SERVICE-VERSION=1.0.0"
    data += "&SECURITY-APPNAME=NilobolA-7c24-4d8e-8eb5-7be038631659"
    data += "&GLOBAL-ID=EBAY-US"
    data += "&RESPONSE-DATA-FORMAT=JSON"
    data += "&REST-PAYLOAD"
    data += "&keywords="
    data += cgi_keyword
    data += "&paginationInput.entriesPerPage="
    data += number_of_product.to_s
    data += "&itemFilter(0).name=ListingType&itemFilter(0).value(0)=FixedPrice"

    http = Net::HTTP.new(url.host,url.port)
    
    response = http.get(url.path+data,headers)
    ebay_result = ActiveSupport::JSON.decode(response.body)
    ebay_products = []
    
    
    return {:ok=>true,:result=>[]} if ((ebay_result["findItemsByKeywordsResponse"][0]["paginationOutput"][0]["totalEntries"][0].to_i == 0) rescue true)
      
    
    begin

      (ebay_result["findItemsByKeywordsResponse"][0]["searchResult"][0]["item"]).each {|item|
        #item = ebay_result["findItemsByKeywordsResponse"][0]["searchResult"][0]["item"][i]
       
        ebay_product = EbayProduct.new
        ebay_product.galleryPlusPictureURL = (item["galleryPlusPictureURL"][0].to_s rescue "")
        ebay_product.listingInfo.listingType = (item["listingInfo"][0]["listingType"][0].to_s rescue "")
        ebay_product.listingInfo.bestOfferEnabled = (item["listingInfo"][0]["bestOfferEnabled"][0].to_s rescue "")
        ebay_product.listingInfo.endTime = (item["listingInfo"][0]["endTime"][0].to_s rescue "")
        ebay_product.listingInfo.startTime = (item["listingInfo"][0]["startTime"][0].to_s rescue "")
        ebay_product.listingInfo.buyItNowAvailable = (item["listingInfo"][0]["buyItNowAvailable"][0].to_s rescue "")
        ebay_product.listingInfo.gift = (item["listingInfo"][0]["gift"][0].to_s rescue "")
        ebay_product.paymentMethod = (item["paymentMethod"][0].to_s rescue "")
        ebay_product.galleryURL = (item["galleryURL"][0].to_s rescue "")
        ebay_product.primaryCategory.categoryId = (item["primaryCategory"][0]["categoryId"][0].to_s rescue "")
        ebay_product.primaryCategory.categoryName = (item["primaryCategory"][0]["categoryName"][0].to_s rescue "")
        ebay_product.viewItemURL = (item["viewItemURL"][0].to_s rescue "")
        ebay_product.title = (item["title"][0].to_s rescue "")
        ebay_product.returnsAccepted = (item["returnsAccepted"][0].to_s rescue "")
        ebay_product.autoPay = (item["autoPay"][0].to_s rescue "")
        ebay_product.itemId = (item["itemId"][0].to_s rescue "")
        ebay_product.country = (item["country"][0].to_s rescue "")
        
        ebay_product.condition.conditionId = (item["condition"][0]["conditionId"][0].to_s rescue "")
        ebay_product.condition.conditionDisplayName = (item["condition"][0]["conditionDisplayName"][0].to_s rescue "")
        
        ebay_product.sellingStatus.sellingState = (item["sellingStatus"][0]["sellingState"][0].to_s rescue "")
        ebay_product.sellingStatus.timeLeft = (item["sellingStatus"][0]["timeLeft"][0].to_s rescue "")
        ebay_product.sellingStatus.convertedCurrentPrice.currencycode = (item["sellingStatus"][0]["convertedCurrentPrice"][0]["@currencyId"].to_s rescue "")
        ebay_product.sellingStatus.convertedCurrentPrice.price = (item["sellingStatus"][0]["convertedCurrentPrice"][0]["__value__"].to_s rescue "")
        ebay_product.sellingStatus.currentPrice.currencycode = (item["sellingStatus"][0]["currentPrice"][0]["@currencyId"].to_s rescue "")
        ebay_product.sellingStatus.currentPrice.price = (item["sellingStatus"][0]["currentPrice"][0]["__value__"].to_s rescue "")
        
        ebay_product.shippingInfo.handlingTime = (item["shippingInfo"][0]["handlingTime"][0].to_s rescue "")
        ebay_product.shippingInfo.shipToLocations = (item["shippingInfo"][0]["shipToLocations"][0].to_s rescue "")
        ebay_product.shippingInfo.expeditedShipping = (item["shippingInfo"][0]["expeditedShipping"][0].to_s rescue "")
        ebay_product.shippingInfo.shippingServiceCost.currencycode = (item["shippingInfo"][0]["shippingServiceCost"][0]["@currencyId"].to_s rescue "")
        ebay_product.shippingInfo.shippingServiceCost.price = (item["shippingInfo"][0]["shippingServiceCost"][0]["__value__"].to_s rescue "")
        ebay_product.shippingInfo.shippingType = (item["shippingInfo"][0]["shippingType"][0].to_s rescue "")
        ebay_product.shippingInfo.oneDayShippingAvailable = (item["shippingInfo"][0]["oneDayShippingAvailable"][0].to_s rescue "")
        
        ebay_product.postalCode = (item["postalCode"][0].to_s rescue "")
        ebay_product.globalId = (item["globalId"][0].to_s rescue "")
        ebay_product.location = (item["location"][0].to_s rescue "")
        
        ebay_products.push(ebay_product)
      }
 
      return {:ok=>true,:result=>ebay_products}
    rescue
      return {:ok=>true,:result=>[]}
    end

  end
end