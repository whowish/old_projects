class SwapController < ApplicationController
  include ApplicationHelper
  
  def index
    @responder_item = Item.first(:conditions=>{:id => params[:responder_item_id]})
    @requestor_item = Item.first(:conditions=>{:id => params[:requestor_item_id]})
    @responder = get_facebook_info(@responder_item.facebook_id)
  end
  
  def sell_form
    @requestor_item = Item.first(:conditions=>{:id => params[:requestor_item_id]})
    @responder = get_facebook_info(@requestor_item.facebook_id)
  end
  
  def buy_form
    @responder_item = Item.first(:conditions=>{:id => params[:responder_item_id]})
    @responder = get_facebook_info(@responder_item.facebook_id)
  end
  
  def save
    
    if !params[:requestor_item_id]
      requestor_item = Item.create(:title=> format_currency_by_country_code($facebook.country_code,params[:offer_money].to_f),
                      :facebook_id=>$facebook.facebook_id,
                      :item_type=>Item::ITEM_TYPE_JUNK,
                      :status=>Item::STATUS_ACTIVE,
                      :category_id=>0,
                      :description=>"",
                      :value=>params[:offer_money],
                      :owner_name=>$facebook.name,
                      :owner_university=>"",
                      :country_code=>$facebook.country_code,
                      :default_image_path=>"",
                      :created_date=>Time.now,
                      :is_money=>1)
                      
      params[:requestor_item_id] = requestor_item.id
    end
    
    @responder_item = nil
    
    if !params[:responder_item_id]
      @responder_item = Item.first(:conditions=>{:id => params[:requestor_item_id]})
      responder_item = Item.create(:title=> format_currency_by_country_code($facebook.country_code,params[:offer_money].to_f),
                      :facebook_id=>$facebook.facebook_id,
                      :item_type=>Item::ITEM_TYPE_WISH,
                      :status=>Item::STATUS_ACTIVE,
                      :category_id=>0,
                      :description=>"",
                      :value=>params[:offer_money],
                      :owner_name=>$facebook.name,
                      :owner_university=>"",
                      :country_code=>$facebook.country_code,
                      :default_image_path=>"",
                      :created_date=>Time.now,
                      :is_money=>1)
                      
      params[:responder_item_id] = responder_item.id
    else
      @responder_item = Item.first(:conditions=>{:id => params[:responder_item_id]})
    end
    
    
    
    @request = Request.new()
    @request.requestor_item_id = params[:requestor_item_id]
    @request.responder_item_id = params[:responder_item_id]
    @request.message = params[:message]
    @request.response_message = ""
    @request.created_date = Time.now
    @request.response_time = Time.now
    @request.status = Request::STATUS_PENDING
    @request.status = Request::STATUS_GUEST_PENDING if $facebook.is_guest
    @request.requestor_facebook_id = $facebook.facebook_id
    @request.responder_facebook_id = @responder_item.facebook_id
    
    if !@request.save
      render :json=>{:ok=>false, :error_message=>format_error(@request.errors)}
      return
    end
    
    if !$facebook.is_guest
      @responder = get_facebook_info(@request.responder_facebook_id)
     
      if @responder.email != nil
        UserMailer.send_later(:deliver_request_swap,@request)
      end
    end
    
    is_redirect = false
    is_share = "no"
    scope = []
    result = {}
    
    if $facebook.facebook_id == "0"
      is_redirect = true
      
      if params[:share_on_facebook] == "yes"
        is_share = "yes"
        scope += [FacebookCache::SCOPE_PUBLISH_STREAM]
      end
    else
      if params[:share_on_facebook] == "yes"
        is_share = "yes"
        scope += [FacebookCache::SCOPE_PUBLISH_STREAM]
        result = $facebook.publish_request_swap(@request)
      end
    end
    
    if is_redirect == true or (result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION)
      
      ticket = ShareTicket.create(:permission=>scope.join(','),
                                  :created_date=>Time.now,
                                  :finished_date=>nil,
                                  :status=>ShareTicket::STATUS_PENDING,
                                  :error_message=>"",
                                  :ref=>"swap item" +@request.id.to_s) 
                                  
      return_url = "http://#{DOMAIN_NAME}/swap/share/#{@request.id.to_s}/#{ticket.unique_key}/#{is_share}"
      redirect_url = generate_permission_url(scope,return_url)
      
      render :json=>{:ok=>true,:redirect_url=>redirect_url}
      return
    end
    
    render :json=>{:ok=>true}

  end
  
  def share
    request = Request.first(:conditions=>{:id=>params[:request_id]})
    
    if request.requestor_facebook_id == "0" and !$facebook.is_guest
      request.requestor_facebook_id = $facebook.facebook_id
      request.status = Request::STATUS_PENDING
      request.save
      
      @responder = get_facebook_info(request.responder_facebook_id)
     
      if @responder.email != nil
        UserMailer.send_later(:deliver_request_swap,request)
      end
    end
    
   ticket = ShareTicket.first(:conditions=>{:unique_key=>params[:share_unique_key]})
    
   if ticket and ticket.status == ShareTicket::STATUS_PENDING

      result = {:ok=>true}
    
      if params[:is_share] == "yes"
        result = $facebook.publish_request_swap(request) if request and request.requestor_facebook_id == $facebook.facebook_id
      end
      
      if result[:ok] == true
        ticket.status = ShareTicket::STATUS_COMPLETED
      else
        ticket.status = ShareTicket::STATUS_ERROR
        ticket.error_message = result[:error_message] if result[:error_message]
      end
      
      ticket.finished_date = Time.now
      
      ticket.save
    end
    
    redirect_to "/"  
  end
  
  def test
    UserMailer.deliver_test
  end
  
end
