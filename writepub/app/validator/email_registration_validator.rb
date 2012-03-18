class EmailRegistrationValidator < Validator

  register_validation :email, [presence,
                                nil,
                                email]
  
end