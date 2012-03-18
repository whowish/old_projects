class EbayProduct
  attr_accessor :galleryPlusPictureURL,:listingInfo,:paymentMethod,:galleryURL,:primaryCategory,:viewItemURL,
                :title,:returnsAccepted,:autoPay,:itemId,:country,:condition,:sellingStatus,:shippingInfo,
                :postalCode,:globalId,:location
 
  def initialize()
    @galleryPlusPictureURL = ""
    
    @listingInfo = EbayListingInfo.new
    @listingInfo.listingType = ""
    @listingInfo.bestOfferEnabled = ""
    @listingInfo.endTime = ""
    @listingInfo.startTime = ""
    @listingInfo.buyItNowAvailable = ""
    @listingInfo.gift = ""
    
    @paymentMethod = ""
    @galleryURL = ""
    
    @primaryCategory = EbayCategory.new
    @primaryCategory.categoryId = ""
    @primaryCategory.categoryName = ""
    
    @viewItemURL = ""
    @title = ""
    @returnsAccepted = ""
    @autoPay = ""
    @itemId = ""
    @country = ""
    
    @condition = EbayCondition.new
    @condition.conditionId = ""
    @condition.conditionDisplayName = ""
    
    @sellingStatus = EbaySellingStatus.new
    @sellingStatus.sellingState = ""
    @sellingStatus.timeLeft = ""
    
    @sellingStatus.convertedCurrentPrice.currencycode = ""
    @sellingStatus.convertedCurrentPrice.price = ""
    
    @sellingStatus.currentPrice.currencycode = ""
    @sellingStatus.currentPrice.price = ""
    @sellingStatus.bidCount = ""
    
    @shippingInfo = EbayShippingInfo.new
    @shippingInfo.handlingTime = ""
    @shippingInfo.shipToLocations = ""
    @shippingInfo.expeditedShipping = ""
    
    @shippingInfo.shippingServiceCost.currencycode = ""
    @shippingInfo.shippingServiceCost.price = ""
    
    @shippingInfo.shippingType = ""
    @shippingInfo.oneDayShippingAvailable = ""
    
    @postalCode = ""
    @globalId = ""
    @location = ""
  end
end

class EbayCategory
  attr_accessor :categoryId, :categoryName
  def initialize()
    @categoryId = ""
    @categoryName = ""
  end
end

class EbayListingInfo
  attr_accessor :listingType, :bestOfferEnabled, :endTime, :startTime, :buyItNowAvailable, :gift
  def initialize()
    @listingType = ""
    @bestOfferEnabled = ""
    @endTime = ""
    @startTime = ""
    @buyItNowAvailable = ""
    @gift = ""
  end
end

class EbayCondition
  attr_accessor :conditionId, :conditionDisplayName
  def initialize()
    @conditionId = ""
    @conditionDisplayName = ""
  end
end

class EbaySellingStatus
  attr_accessor :sellingState, :timeLeft,:convertedCurrentPrice,:currentPrice,:bidCount
  def initialize()
    @sellingState = ""
    @timeLeft = ""
    
    @convertedCurrentPrice = EbayCurrency.new
    @convertedCurrentPrice.currencycode = ""
    @convertedCurrentPrice.price = ""
    
    @currentPrice = EbayCurrency.new
    @currentPrice.currencycode = ""
    @currentPrice.price = ""
    
    @bidCount = ""
  end
end

class EbayCurrency
  attr_accessor :currencycode, :price
  def initialize()
    @currencycode = ""
    @price = ""
  end
end

class EbayShippingInfo
  attr_accessor :handlingTime, :shipToLocations,:expeditedShipping,:shippingServiceCost,:shippingType,:oneDayShippingAvailable
  def initialize()
    @handlingTime = ""
    @shipToLocations = ""
    @expeditedShipping = ""
    
    @shippingServiceCost = EbayCurrency.new
    @shippingServiceCost.currencycode = ""
    @shippingServiceCost.price = ""
    
    @shippingType = ""
    @oneDayShippingAvailable = ""
  end
end