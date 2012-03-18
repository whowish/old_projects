class MemberValidator < Validator

  register_validation :username, [presence,
                                nil,
                                min_length(4),
                                max_length(50)]
  
  register_validation :password, [presence,
                                  nil,
                                  max_length(255)]
  
end