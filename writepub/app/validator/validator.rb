class Validator
  
  @__fields_to_validate = nil
  @__fields_to_validate_uniqueness = nil
  @__being_checked_method = nil
  @__instance = nil
  
  class << self

    # A hook that turns every method into curriable lambda
    #
    #
    #
    def method_added(method_name)
      
#      puts "#{method_name} added to #{self}"
      
      return if method_name == :validate
      return if method_name.to_s.match(/^validation__proxy__/)
      return if @__being_checked_method == method_name
      
      manually_add_method(method_name)
  
    end
    
    def manually_add_method(method_name)
      
      @__being_checked_method = method_name
      
      new_name = "validation__proxy__#{method_name}".to_sym
      
      return if self.method_defined?(new_name)
      
      alias_method new_name, method_name
      
      define_singleton_method(method_name) { |*args| 
          
          @__instance ||= self.new
          l = lambda(&(@__instance.method(new_name))).curry
          
          args.each { |a|
            l = l.curry[a]
          }
          
          v = ValidatorFunctionUnit.new
          v.proc = l
          v.name = method_name
          
          return v
      }
      
    end


    # Register the validations here
    #
    #
    #
    def register_validation(field_sym,lamb_func_with_message)
      
      lamb_func_with_message.each_index { |i|
        if lamb_func_with_message[i].instance_of?(ValidatorFunctionUnit)
          lamb_func_with_message[i] = {:f=>lamb_func_with_message[i]}
        end
      }

      @__fields_to_validate ||= {}
      @__fields_to_validate[field_sym] ||= []
      @__fields_to_validate[field_sym] += lamb_func_with_message
      
#      puts @__fields_to_validate.inspect
    end

    # Register the uniqueness validations
    #
    #
    #
    def register_uniqueness(field_sym)

      @__fields_to_validate_uniqueness ||= {}
      @__fields_to_validate_uniqueness[field_sym] = true
      
#      puts @__fields_to_validate_uniqueness.inspect
    end
    
    # validate uniqueness of key from MongoDB's last error message
    # It is a hash object that looks like this:
    #   {"err"=>"E11000 duplicate key error index: writepub.members.$email_1  dup key: { : \"xxx\" }", 
    #    "code"=>11000, 
    #    "n"=>0, 
    #    "connectionId"=>20, 
    #    "ok"=>1.0}
    def validate_uniqueness(error_from_mongodb=nil)
      
      if error_from_mongodb == nil
        error_from_mongodb = Mongoid.database.command({:getlasterror => 1})
      end
      
      return {} if error_from_mongodb["code"] == nil
      
      index_name = error_from_mongodb["err"].match(/E11000 +duplicate +key +error +index: +([^ ]+) +/)
      return {:unique=>error_from_mongodb["err"]} if index_name == nil

      database,collection,index_name = index_name[1].split('.')
      return {:unique=>error_from_mongodb["err"]} if index_name == nil

      field_sym = index_name[1..-1].sub(/_-1$/,'').sub(/_1/,'').sub('_downcase','').to_sym
      return {field_sym=>word_for(field_sym,'uniqueness')}
      
    end
    
    def validate(all_params)

      error_messages = {}
      
#      puts @__fields_to_validate.inspect
      
      @__fields_to_validate.each_pair { |key,list|
  
        this_error_messages = []
        
        list.each { |func_with_msg|
          break if this_error_messages.length > 0 and func_with_msg == nil # breaker
          next if func_with_msg == nil # skip
          
          if func_with_msg[:f].proc.call(all_params[key]) == false
            this_error_messages.push( (func_with_msg[:m] ? func_with_msg[:m] : word_for(key,func_with_msg[:f].name) ) )
          end
        }
        
        if this_error_messages.length > 0
          error_messages[key] = this_error_messages
        end
      }
      
      return error_messages
      
    end
    
    def word_for(field,func_name)
      WhowishWord.word_for(self.name.sub("Validator","").underscore,"#{field}_#{func_name}")
    end
  end
  
  include ValidatorHelper
  
  ValidatorHelper.instance_methods.each { |method_name|
    manually_add_method(method_name)
  }
end

