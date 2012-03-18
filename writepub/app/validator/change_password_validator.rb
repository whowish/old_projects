class ChangePasswordValidator < Validator

  register_validation :old_password, [presence,
                                  nil,
                                  min_length(4)]
   register_validation :new_password, [presence,
                                  nil,
                                  min_length(4)]
  
end
