class RecoverPasswordValidator < Validator
   
   register_validation :password, [presence,
                                  nil,
                                  min_length(4)]
  
end
