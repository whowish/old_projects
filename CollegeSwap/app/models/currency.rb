class Currency < ActiveRecord::Base
  
 def self.get_by_country_code(country_code)
   currency = Currency.first(:conditions=>{:country_code=>country_code})
   currency = Currency.first(:conditions=>{:country_code=>"US"}) if !currency
   return currency
 end
 
 def self.get_by_currency_code(currency_code)
   currency = Currency.first(:conditions=>{:paypal_currency_code=>currency_code})
   currency = Currency.first(:conditions=>{:paypal_currency_code=>"USD"}) if !currency
   return currency
 end
end