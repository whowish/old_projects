class TakeController < ApplicationController
  def index 
    @requestor_item= Item.first(:conditions=>{:id => params[:requestor_item_id]})
    @responder = get_facebook_info(@requestor_item.facebook_id)
    @responder_junk_list = Item.all(:conditions=>{:facebook_id => @responder.facebook_id,:item_type=>Item::ITEM_TYPE_JUNK,:status=>Item::STATUS_ACTIVE,:is_money=>0})
  end
  
  def send_remind_email
    message = ""
    if params[:message] != "" and params[:message] != nil
      message = params[:message]
    end
    
    item_title = params[:item_title]
    requestor = get_facebook_info($facebook.facebook_id)
    responder = get_facebook_info(params[:responder_id])
    
    if responder.email != nil
      UserMailer.send_later(:deliver_remind_no_item,requestor,responder,message,item_title)
    end
      render :json => {:ok=>true}
  end
end
