class CommentPending < ActiveRecord::Base
  STATUS_PENDING = "PENDING"
  STATUS_DONE = "DONE"
  
  before_create :generate_unique_key
  
  def generate_unique_key
    if self.unique_key != nil
      return
    end
    
    srand(Time.now.to_i + 1)
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'
    
    token = ""
    success = false
    while !success 
      
      token = ''
      10.times { token << chars[rand(chars.size)] }
    
      if !self.class.first(:conditions=>{:unique_key=>token})
        break;
      end
    end
    
    self.unique_key = token
  end
  
end