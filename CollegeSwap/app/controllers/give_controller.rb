class GiveController < ApplicationController
  def index 
    @responder_item = Item.first(:conditions=>{:id => params[:responder_item_id]})
    @responder = get_facebook_info(@responder_item.facebook_id)
    @my_junk_list = Item.all(:conditions=>{:facebook_id => $facebook.facebook_id,:item_type=>Item::ITEM_TYPE_JUNK,:status=>Item::STATUS_ACTIVE,:is_money=>0})
    @responder_wish_list = Item.all(:conditions=>{:facebook_id => @responder.facebook_id,:item_type=>Item::ITEM_TYPE_WISH,:status=>Item::STATUS_ACTIVE,:is_money=>0})
  end
end
