class InboxController < ApplicationController
  def index
    
  end
  
  def get_email
    if $facebook.email == nil
      user = get_facebook_info($facebook.facebook_id,true)
      $facebook.email = user.email
    end
    
    render :index
  end
  
  def read
    Request.update_all({:is_read=>1},["requestor_facebook_id =? AND status in (?) AND is_read=0", $facebook.facebook_id, [Request::STATUS_ACCEPTED, Request::STATUS_REJECTED]])

    render :json=>{:ok=>true}
  end
  
  def save_response
    @response = Request.first(:conditions=>{:id=> params[:request_id]})
    @response.status = params[:status]
    @response.response_message = params[:response_message]
    @response.response_time = Time.now

    if !@response.save
      render :json => {:ok=>false,:error_message=>""}
      return
    end
    
    requestor = get_facebook_info(@response.requestor_facebook_id)
    if @response.status == Request::STATUS_REJECTED
      if requestor.email != nil
        UserMailer.send_later(:deliver_response_swap_reject,@response)
      end
      render :json => {:ok=>true,:html=> render_to_string(:partial=>"completed", :layout=>"blank",:locals=>{:request=>@response})}
    
    elsif @response.status == Request::STATUS_ACCEPTED
      if requestor.email != nil
        UserMailer.send_later(:deliver_response_swap_accept,@response)
      end

      junk = Item.first(:conditions=>{:id=> @response.responder_item_id})
      
      if junk.category_id != 4
        junk.status = Item::STATUS_COMPLETED
        junk.save
      end 
      
      
      wish = Item.first(:conditions=>{:id=> @response.requestor_item_id})
      
      if wish.category_id != 4
        wish.status = Item::STATUS_COMPLETED
        wish.save
      end
      
      result = {}
      if params[:share_on_facebook] == "yes"
        result = $facebook.publish_response_swap(@response)
      end
      
      if result[:ok] == false and result[:error_id] == FacebookCache::ERROR_NO_PERMISSION
        
          scope = [FacebookCache::SCOPE_PUBLISH_STREAM]
         ticket = ShareTicket.create(:permission=>scope.join(','),
                                  :created_date=>Time.now,
                                  :finished_date=>nil,
                                  :status=>ShareTicket::STATUS_PENDING,
                                  :error_message=>"",
                                  :ref=>"respond swap item" +@response.id.to_s) 
        
        render :json => {:ok=>true,
                        :redirect_url=>generate_permission_url(scope,"http://#{DOMAIN_NAME}/inbox/share_after_response/#{@response.id}/#{ticket.unique_key}")}
      else
        render :json => {:ok=>true,
                        :html=> render_to_string(:partial=>"completed", :layout=>"blank",:locals=>{:request=>@response}),
                        }
      end
      
    end
  end
  
  def share_after_response
    request = Request.first(:conditions=>{:id=>params[:request_id]})
    
    ticket = ShareTicket.first(:conditions=>{:unique_key=>params[:share_unique_key]})
    
    if ticket and ticket.status == ShareTicket::STATUS_PENDING

      result = {:ok=>true}
      if request.status == Request::STATUS_ACCEPTED
        result = $facebook.publish_response_swap(request) if request and request.responder_facebook_id == $facebook.facebook_id
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
    
    redirect_to "/inbox"  
  end
  
  def renew
    item = Item.first(:conditions=>{:id=>params[:item_id]})
    item.status = Item::STATUS_ACTIVE
    item.created_date = Time.now
    item.save
    
  end
  
  def delete
    obj = Request.first(:conditions=>{:id=> params[:request_id]})
    obj.destroy
    render :json=>{:ok=>true}
  end
end
