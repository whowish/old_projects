class OrderController < ApplicationController
  include OrderHelper
  include FriendPosterHelper
  
  def create
    
    @order = Order.new
    @order.status = Order::STATUS_CREATING
    @order.facebook_id = $member.facebook_id
    @order.created_date = Time.now
    @order.app_id = params[:app_id]
    @order.save
    
#    friends = $facebook.query("SELECT uid2 FROM friend WHERE uid1=me()")
    
#    logger.debug { "friends=#{friends.length}" }
#    logger.debug { "friends=#{$facebook.query("SELECT cover_pid FROM album WHERE owner IN ('#{friends[0..120].map{|d|d['uid2']}.join("','")}') AND type='profile'").length}" }
#    logger.debug { "friends=#{$facebook.query("SELECT cover_pid FROM album WHERE owner IN ('#{friends[120..240].map{|d|d['uid2']}.join("','")}') AND type='profile'").length}" }
#    logger.debug { "friends=#{$facebook.query("SELECT cover_pid FROM album WHERE owner IN ('#{friends[240..360].map{|d|d['uid2']}.join("','")}') AND type='profile'").length}" }

#    image_urls = $facebook.query("SELECT src_big FROM photo WHERE pid IN (SELECT cover_pid FROM album WHERE owner IN (SELECT uid2 FROM friend WHERE uid1=me()) AND type='profile')").map{ |d| d['src_big'] }
    image_urls = $facebook.query("SELECT pic_big FROM profile WHERE id IN (SELECT uid2 FROM friend WHERE uid1=me())").map{ |d| d['pic_big'] }
    
    logger.debug { "image_urls.length=#{image_urls.length}"}
    
    begin
      
      poster, redirect_url, error_message = create_friend_poster(image_urls.join(","),@order.key)
      
      if poster   
        render :json=>{:ok=>true,:redirect_url=>redirect_url}
      else
        render :json=>{:ok=>false,:error_message=>error_message}
      end
    rescue Exception=>e
      render :json=>{:ok=>false,:error_message=>"Error: #{e}"}
    end
  end
  
  def pricing
    
    ok, error_message = submit_order_price(params[:order_key],params[:price])
    render :json=>{:ok=>ok,:error_message=>error_message}
    
  end
  
#  skip_before_filter :verify_authenticity_token, :only=>[:set_print_image_url]
#  def set_print_image_url
#    
#    order = Order.first(:conditions=>{:key=>params[:order_key]})
#    order.print_image_url = params[:print_image_url]
#    order.singature_image_url = params[:signature_image_url]
#    order.save
#    
#    render :json=>{:ok=>true}
#    
#  end
  
  def save_address
    
    member = Member.first(:conditions=>{:facebook_id => $facebook.facebook_id})
    if !member
       render :json=>{:ok=>false, :error_message=>"please login first."}
       return
    end
    
    member.recipient_name = params[:recipient_name]
    member.address_identifier = params[:address_identifier]
    member.address_street = params[:address_street]
    member.address_subdistrict = params[:address_subdistrict]
    member.address_district = params[:address_district]
    member.address_province = params[:address_province]
    member.address_postal_code = params[:address_postal_code]
    member.save  
    
    @order = Order.first(:conditions=>{:key=>params[:order_key]})
    @order.recipient_name = params[:recipient_name]
    @order.address_identifier = params[:address_identifier]
    @order.address_street = params[:address_street]
    @order.address_subdistrict = params[:address_subdistrict]
    @order.address_district = params[:address_district]
    @order.address_province = params[:address_province]
    @order.address_postal_code = params[:address_postal_code]
    

    if !@order.save
      render :json=>{:ok=>false, :error_message=>format_error(@order.errors)}
      return
    end

    #render :json=>{:ok=>true,:order_id=>@order.id,:html=>(render_to_string :partial=>"order/view_page",:locals=>{:order=>@order})}
    render :json=>{:ok=>true,:url=>"/order/order_successfully?order_key="+@order.key.to_s}
  end
  
  def customer_confirm_transfer
    @order = Order.first(:conditions=>{:key => params[:order_key]})
    
    if !@order
      render :json=>{:ok=>false, :error_message=>"The order is not exist."}
      return
    end
    
    confirm_transfer = ConfirmTransfer.new()
    confirm_transfer.order_id = @order.id
    confirm_transfer.transfer_to_bank_id = params[:bank_id]
    confirm_transfer.member_tel = params[:member_tel]
    confirm_transfer.transfer_from_branch = params[:transfer_from_branch]
    confirm_transfer.transfer_price = params[:transfer_price]
    split_date = params[:transfer_date].split(' ');
    confirm_transfer.transfer_date = Time.mktime(split_date[2], split_date[1], split_date[0], params[:hour], params[:min])
    confirm_transfer.created_date = Time.now
    confirm_transfer.save
    
    @order.status = Order::STATUS_CUSTOMER_CONFIRM_TRANSFER
    
    if confirm_transfer.transfer_price < @order.price
      payment_issue = PaymentIssue.new()
      payment_issue.order_id = @order.id
      payment_issue.issue = "Customer transfer the money less than order's price."
      payment_issue.save
    end
    
    if !@order.save
      render :json=>{:ok=>false, :error_message=>format_error(@order.errors)}
      return
    end
    render :json=>{:ok=>true,:url=>"/order/transfer_successfully?order_key="+@order.key}
  end
  
  def customer_cancel
    @order = Order.first(:conditions=>{:id => params[:order_id]})
    
    if !@order
      render :json=>{:ok=>false, :error_message=>"The order is not exist."}
      return
    end
    
     if @order.status == Order::STATUS_PRINTING or @order.status == Order::STATUS_SHIPPING
      render :json=>{:ok=>false, :error_message=>"You can't cancel this order because it's printed."}
      return
    end
    
    cancel_order = CancelOrder.new()
    
    cancel_order.order_id = @order.id
    cancel_order.reason = params[:reason]
    cancel_order.cus_account_number = params[:cus_account_number]
    cancel_order.created_date = Time.now
    cancel_order.old_status = @order.status
    cancel_order.save
    
    @order.status = Order::STATUS_PENDING_CANCELLED
    
    if !@order.save
      render :json=>{:ok=>false, :error_message=>format_error(@order.errors)}
      return
    end
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"/my_order/order_unit",:locals=>{:order=>@order})}
  end
  
  def pay_by_paypal
    order = Order.first(:conditions=>{:key=> params[:order_key]})
#    order.price = 300
    
    pay_key = request_pay_key(order)
    
    print pay_key
    if !pay_key
      render :json => {:ok =>false,:error_message=>"Cannot connect to PayPal. Please try again later."}
      return
    end
    
    order.paypal_pay_key = pay_key
      
    if !order.save
      render :json=>{:ok=>false, :error_message=>"Data invalid.", :log=>format_error(order.errors)}
      return
    end
    
    render :json => { :ok=>true, :url=>PAYPAL_REDIRECT_URL + "?cmd=_ap-payment&paykey="+pay_key }
  
  end

  def paid_successfully
    
    order = Order.first(:conditions=>{:key=>params[:order_key]})
    if !order
      render :data_error
      return
    end
   
    if confirm_payment(order)
      Lock.generate("Paypal",order.key).synchronize {
      
        order = Order.first(:conditions=>{:key=>order.key})
        
        if order.status == Order::STATUS_PENDING
        
          successfully_order(order,Order::PAYMENT_TYPE_PAYPAL)
        
        end
      
      }
    else
      render :data_error
      return
    end
  end
  
end
