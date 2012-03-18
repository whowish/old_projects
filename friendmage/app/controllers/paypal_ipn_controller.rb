class PaypalIpnController < ApplicationController
  include OrderHelper
 
 protect_from_forgery :except => [:index]
  
  def index

    entity = PaypalIpn.new
    
    begin

      entity.raw = request.raw_post
      entity.created_date = Time.now
      entity.remote_host = request.remote_ip
      entity.status = PaypalIpn::STATUS_PENDING
      entity.order_id = 0
      entity.test_ipn = params[:test_ipn]
      entity.transaction_type = params[:transaction_type]
      entity.sender_email = params[:sender_email]
      entity.pay_key = params[:pay_key]
      entity.payment_status = params[:status]

      if !entity.save
        render :text=>"Your machine is infected with a serious virus. Please fix before making a connection to WhoWish server."
        return
      end
  
      require 'net/http'
      require 'net/https'
      require 'uri'
      
      Net::HTTP.version_1_2
      
      url = URI.parse(PAYPAL_IPN_VERIFICATION_URL)
  
      http = Net::HTTP.new(url.host,url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      
      nvp = 'cmd=_notify-validate'
      
      request.raw_post.split('&').each { |p|
        k,v = p.split('=')
        k = "" if !k
        v = "" if !v
        nvp += "&#{k}=#{URI.encode(CGI.unescape(v))}"
      }
      
      entity.raw = request.raw_post + " " + nvp
      
      response = nil
      
      retry_count = 0
      
      while true
        begin
          response = http.post(url.path,nvp)
          break
        rescue Exception=>e
          retry_count = retry_count + 1
          
          raise e if retry_count > 5
        end
      end
      
      entity.paypal_status = response.body
      
      entity.save
      
      if response.body.strip != "VERIFIED"
        
        entity.status = PaypalIpn::STATUS_INVALID
        entity.save
        
        render :text=>"Your machine is infected with the virus, which is erasing all data soon. Please fix before making a connection to WhoWish server. #{nvp}"
        return
      end
      
      order = Order.first(:conditions=>{:paypal_pay_key=>params[:pay_key]})
      
      if !order
        entity.status = PaypalIpn::STATUS_INVALID
        entity.order_id = 0
        entity.save
        
        render :text=>"INVALID"
        return
      end
  
      entity.status = PaypalIpn::STATUS_VERIFIED
      entity.order_id = order.id
      entity.save
      
      # processed
      if entity.payment_status.upcase == "COMPLETED"
        
        Lock.generate("Paypal",order.key).synchronize {
          
          order = Order.first(:conditions=>{:key=>order.key})
          if order.status == Order::STATUS_PENDING
          
            successfully_order(order,Order::PAYMENT_TYPE_PAYPAL)
          
          end
        
        }
      end
    
      render :text=>"VERIFIED"
    rescue Exception=>e
      entity.error = "#{e}\n #{e.to_s_with_trace}"
      entity.save
    end
  end
 
end
