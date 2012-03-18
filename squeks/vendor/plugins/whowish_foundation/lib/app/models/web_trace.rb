class WebTrace < ActiveRecord::Base
  
  before_create :generate_unique_key
  
  def generate_unique_key
    return if self.unique_key != nil
    
    
    
    srand(Time.now.to_i + 1)
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'

    token = ""
    success = false
    while !success 
      
      token = ''
      10.times { token << chars[rand(chars.size)] }
      
      self.unique_key = "#{self.ip_address} #{self.time.to_f} #{token}"

      if !self.class.first(:conditions=>{:unique_key=>self.unique_key})
        break;
      end
    end
    
  end
  
end
