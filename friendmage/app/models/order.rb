class Order < ActiveRecord::Base
  STATUS_CREATING = "CREATING"
  STATUS_PENDING = "PENDING"
  STATUS_CUSTOMER_CONFIRM_TRANSFER = "CUSTOMER_CONFIRM_TRANSFER"
  STATUS_PAID = "PAID"
  STATUS_PRINTING = "PRINTING"
  STATUS_SHIPPING = "SHIPPING"
  STATUS_PENDING_CANCELLED = "PENDING_CANCELLED"
  STATUS_CANCELLED = "CANCELLED"
  
  PAYMENT_TYPE_PAYPAL = "PAYPAL"
  PAYMENT_TYPE_TRANSFER = "TRANSFER"
  
  before_create :generate_unique_key
  
  def generate_unique_key
    
      if self.key != nil
        return
      end
      
      srand(Time.now.to_i + 1)
      chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNPQRSTUVWXYZ23456789'

      token = ""
      success = false
      while !success 
        
        token = ''
        20.times { token << chars[rand(chars.size)] }

        if !self.class.first(:conditions=>{:key=>token})
          break;
        end
      end

      self.key = token
  end
  
  def get_symbol_status
#    return_symbol = ""
#    if self.status == Order::STATUS_CANCELLED
#      return_symbol == "status_cancelled"
#    end
#    score = 70

    return self.status.downcase

  end
end