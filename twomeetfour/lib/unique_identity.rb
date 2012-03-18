module UniqueIdentity

    def generate_unique_key
      
      srand(Time.now.to_i + 1)
      chars = ['abcdefghjkmnpqrstuvwxyz23456789','ABCDEFGHJKLMNPQRSTUVWXYZ23456789']
      
      token = ""
      success = false
      count = 0
      while !success
      
        selected_chars = chars[rand(chars.size)]
        
        token = ''
        10.times { token << selected_chars[rand(selected_chars.size)] }

        self.class::Uuid.unsafely.create(:id=>token)
        last_error = Mongoid.database.command({:getlasterror => 1})
        
        break if last_error['code'].to_i != 11000
        
        count += 1
        if count > 200
          raise "#{self.class.name} cannot be added because its unique ID is exhausted."
        end
      end
      

      self.id = token
    end

    def self.included(mod)
      mod.class_eval do
        mod.identity :type => String
        mod.before_create :generate_unique_key
        
        uuid = mod.const_set("Uuid",Class.new)
  
        uuid.class_eval do
            include Mongoid::Document 
            identity :type => String
        end
      end
    end
end