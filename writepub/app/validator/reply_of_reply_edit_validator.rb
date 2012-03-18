class ReplyOfReplyEditValidator < Validator

  register_validation :content, [presence,
                                  nil,
                                  max_length(10000000)]
  
end