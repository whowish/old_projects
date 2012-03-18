class KratooValidator < Validator

  def check_type(value)
    
    return (value == Kratoo::TYPE_GENERAL)
  end
  
  
  register_validation :title, [presence,
                                nil,
                                max_length(255)]
  
  register_validation :content, [presence,
                                  nil,
                                  max_length(10000000)]
  
  register_validation :kratoo_type, [check_type]
  
end
