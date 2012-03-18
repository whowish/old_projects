module OrderHelper
  include FriendPosterHelper
  include BirthdayCalendarHelper
  
  def create_order(app_id)
    order = Order.new
    order.status = Order::STATUS_CREATING
    order.facebook_id = $member.facebook_id
    order.created_date = Time.now
    order.app_id = app_id
    
    Lock.generate("NewOrder").synchronize {
      order.save
    }
    
    return order
  end
  
  def submit_order_price(order_key,price,buy_digital_copy,buy_print_copy)
    order = Order.first(:conditions=>{:key=>order_key})
    order.price = price
    order.buy_digital_copy = buy_digital_copy
    order.buy_print_copy = buy_print_copy
    order.status = Order::STATUS_PENDING
    order.save
    
    return true, ""
  end
  
  def successfully_order(order,payment_type)
      order.status = Order::STATUS_PAID
      order.payment_type = payment_type
      order.paid_time = Time.now
      order.save
      
      begin 
        if order.app_id == "FriendPoster"
          
          queue_friend_poster_generator(order.key)
        elsif order.app_id == "BirthdayCalendar"
          
          queue_birthday_calendar_generator(order.key)
        end
      rescue Exception=>e
        logger.error { "Trigger ImageGenerator error #{e.to_s_with_trace}" }
      end
  end
  
  def regenarate_image(order)
    begin 
        if order.app_id == "FriendPoster"
          
          queue_friend_poster_generator(order.key)
        elsif order.app_id == "BirthdayCalendar"
          
          queue_birthday_calendar_generator(order.key)
        end
        order.print_image_url = nil
        order.preview_image_url = nil
        order.signature_image_url = nil
        order.save
      rescue Exception=>e
        logger.error { "Trigger ImageGenerator error #{e.to_s_with_trace}" }
      end
  end
  
  def request_pay_key(order)
    headers = {
       "X-PAYPAL-SECURITY-USERID" => PAYPAL_API_USERNAME,
       "X-PAYPAL-SECURITY-PASSWORD" => PAYPAL_API_PASSWORD,
       "X-PAYPAL-SECURITY-SIGNATURE" => PAYPAL_API_SIGNATURE,
       #"X-PAYPAL-SECURITY-SUBJECT" => "",
       "X-PAYPAL-REQUEST-DATA-FORMAT" => "JSON",
       "X-PAYPAL-RESPONSE-DATA-FORMAT" => "JSON",
       "X-PAYPAL-APPLICATION-ID" => PAYPAL_API_APP_ID
       #"X-PAYPAL-DEVICE-ID" => "",
       #"X-PAYPAL-DEVICE-IPADDRESS" => "",
       #"X-PAYPAL-SERVICE-VERSION" => "1.3.0"
    }

    data = {
      "actionType" => "PAY",
      "receiverList" => {"receiver"=>[{"email"=>PAYPAL_RECEIVER,
                                      "amount"=>(order.price.to_f).round(2).to_s,
                                      "invoiceId"=>order.key
                                      }]},
      "currencyCode" => "THB",
      "cancelUrl" => "http://"+DOMAIN_NAME+"/my_order",
      "returnUrl" => "http://"+DOMAIN_NAME+"/order/paid_successfully?order_key="+order.key.to_s,
      "requestEnvelope" => {"errorLanguage"=>"en_US"},
      "ipnNotificationUrl" => PAYPAL_IPN_URL,
      "memo" => "#{order.app_id}"
      #"senderEmail" => "tanin47@gmail.com"
    }

    require 'net/http'
    require 'net/https'
    require 'uri'
    
    Net::HTTP.version_1_2

    url = URI.parse(PAYPAL_REQUEST_PAY_KEY_URL)

    http = Net::HTTP.new(url.host,url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    response = http.post(url.path,ActiveSupport::JSON.encode(data),headers)
    logger.debug{"response from paypal "+ response.body }
    result = ActiveSupport::JSON.decode(response.body)

    if result["responseEnvelope"]["ack"] == "Success"
      return result["payKey"];
    else
      return nil
    end 
  end
  
#  def test_paypal()
#    headers = {
#       "X-PAYPAL-SECURITY-USERID" => PAYPAL_API_USERNAME,
#       "X-PAYPAL-SECURITY-PASSWORD" => PAYPAL_API_PASSWORD,
#       "X-PAYPAL-SECURITY-SIGNATURE" => PAYPAL_API_SIGNATURE,
#       #"X-PAYPAL-SECURITY-SUBJECT" => "",
#       "X-PAYPAL-REQUEST-DATA-FORMAT" => "JSON",
#       "X-PAYPAL-RESPONSE-DATA-FORMAT" => "JSON",
#       "X-PAYPAL-APPLICATION-ID" => PAYPAL_API_APP_ID
#       #"X-PAYPAL-DEVICE-ID" => "",
#       #"X-PAYPAL-DEVICE-IPADDRESS" => "",
#       #"X-PAYPAL-SERVICE-VERSION" => "1.3.0"
#    }
#    
#    
#    data = {
#      "actionType" => "PAY",
#      "receiverList" => {"receiver"=>[{
#                                      "email"=>PAYPAL_RECEIVER,
#                                      "amount"=>"1.00",
#                                      "invoiceId"=>"xxxx19"
#                                      }]},
#      "currencyCode" => "USD",
#      "cancelUrl" => "http://www.google.com",
#      "returnUrl" => "http://www.yahoo.com",
#      "requestEnvelope" => {"errorLanguage"=>"en_US"}
#      #"senderEmail" => "tanin47@gmail.com"
#    }
#
#    require 'net/http'
#    require 'net/https'
#    require 'uri'
#    
#    Net::HTTP.version_1_2
#
#    url = URI.parse(PAYPAL_REQUEST_PAY_KEY_URL)
#
#    http = Net::HTTP.new(url.host,url.port)
#    http.use_ssl = true
#    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
#
#    response = http.post(url.path,ActiveSupport::JSON.encode(data),headers)
#    print response.body
#    result = ActiveSupport::JSON.decode(response.body)
#
#    if result["responseEnvelope"]["ack"] == "Success"
#      return result["payKey"];
#    else
#      return nil
#    end 
#  end
#  
  def confirm_payment(order)
    headers = {
        "X-PAYPAL-SECURITY-USERID" => PAYPAL_API_USERNAME,
       "X-PAYPAL-SECURITY-PASSWORD" => PAYPAL_API_PASSWORD,
       "X-PAYPAL-SECURITY-SIGNATURE" => PAYPAL_API_SIGNATURE,
       #"X-PAYPAL-SECURITY-SUBJECT" => "",
       "X-PAYPAL-REQUEST-DATA-FORMAT" => "JSON",
       "X-PAYPAL-RESPONSE-DATA-FORMAT" => "JSON",
       "X-PAYPAL-APPLICATION-ID" => PAYPAL_API_APP_ID
       #"X-PAYPAL-DEVICE-ID" => "",
       #"X-PAYPAL-DEVICE-IPADDRESS" => "",
       #"X-PAYPAL-SERVICE-VERSION" => "1.3.0"
    }
    
    data = {
      "payKey" => order.paypal_pay_key,
      "requestEnvelope" => {"errorLanguage"=>"en_US"}
      #"senderEmail" => "tanin47@gmail.com"
    }
    

    require 'net/http'
    require 'net/https'
    require 'uri'
    
    Net::HTTP.version_1_2

    url = URI.parse(PAYPAL_PAYMENT_DETAIL_URL)

    http = Net::HTTP.new(url.host,url.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE


    response = http.post(url.path,ActiveSupport::JSON.encode(data),headers)

    result = ActiveSupport::JSON.decode(response.body)

    if result["status"] == "COMPLETED"
      return true
    else
      return false
    end 
  end
end
