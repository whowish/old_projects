module Validator

  module ValidatorHelper
  
    def presence(value)
      value ||= ""
      return !(value.strip == "")
    end
    
    def email(value)
      value ||= ""
      return (value.match(/.+@.+/) != nil)
    end
  
    def max_length(length,value)
      value ||= ""
      return (value.length <= length)
    end
    
    def min_length(length,value)
      value ||= ""
      return (value.length >= length)
    end
  
  end

end