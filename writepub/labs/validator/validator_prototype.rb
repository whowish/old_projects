
module ValidatorHelper

  def presence(value)
    value ||= ""
    return !(value.strip == "")
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
class Validator
  
  cattr_accessor :__fields_to_validate, :__being_checked_method
  
  class << self

    # A hook that turns every method into curriable lambda
    #
    #
    #
    def method_added(method_name)
      
#      puts "#{method_name} added to #{self}"
      
      return if method_name == :validate
      return if method_name.to_s.match(/^validation__proxy__/)
      return if @@__being_checked_method == method_name
      
      manually_add_method(method_name)
  
    end
    
    def manually_add_method(method_name)
      
      @@__being_checked_method = method_name
      
      new_name = "validation__proxy__#{method_name}".to_sym
      
      return if self.method_defined?(new_name)
      
      alias_method new_name, method_name
      
      define_singleton_method(method_name) { |*args| 

          l = lambda(&(self.new.method(new_name))).curry
          
          args.each { |a|
            l = l.curry[a]
          }
          
          return l
      }
      
    end


    # Register the validations here
    #
    #
    #
    def register_validation(field_sym,lamb_func_with_message)

      @@__fields_to_validate ||= {}
      @@__fields_to_validate[field_sym] ||= []
      @@__fields_to_validate[field_sym] += lamb_func_with_message
      
      puts @@__fields_to_validate.inspect
    end
    
    def validate(all_params)

      error_messages = {}
      
      puts @@__fields_to_validate.inspect
      
      @@__fields_to_validate.each_pair { |key,list|
  
        this_error_messages = []
        
        list.each { |func_with_msg|
          break if this_error_messages.length > 0 and func_with_msg == nil # breaker
          next if func_with_msg == nil # skip
          
          puts "call #{func_with_msg.inspect}"
          if func_with_msg[:f].call(all_params[key]) == false
            this_error_messages.push( (func_with_msg[:m].instance_of?(Proc) ? func_with_msg[:m].call: func_with_msg[:m]) )
          end
        }
        
        if this_error_messages.length > 0
          error_messages[key] = this_error_messages
        end
      }
      
      return error_messages
      
    end
    
    def word_for(id)
      return lambda { return WhowishWord.word_for(self.name,id) }
    end
  end
  
  include ValidatorHelper
  
  ValidatorHelper.instance_methods.each { |method_name|
    manually_add_method(method_name)
  }
end



class KratooValidator < Validator
   
  
  register_validation :title, [{:f=>presence,:m=>"word_for(:title_presence)"},
                              {:f=>max_length(255),:m=>"Title is too long."},
                              {:f=>min_length(10),:m=>"Title is too short."}]
  
  register_validation :content, [{:f=>presence,:m=>"Content cannot be blank."},
                              {:f=>max_length(10000000),:m=>"Content is too long."},
                              {:f=>min_length(10),:m=>"Content is too short."}]
  
end


puts KratooValidator.validate({:title=>""})
