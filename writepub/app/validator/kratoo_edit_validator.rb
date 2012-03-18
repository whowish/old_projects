class KratooEditValidator < Validator
  
  register_validation :title, [presence,
                                nil,
                                max_length(255)]
  
  register_validation :content, [presence,
                                  nil,
                                  max_length(10000000)]
  
end