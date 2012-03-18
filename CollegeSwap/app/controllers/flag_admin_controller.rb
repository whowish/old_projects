class FlagAdminController < ApplicationController
  
  layout "valhalla"
  
  def index
    
  end
  def abuse
    @item = Item.first(:conditions=>{:id=> params[:item_id]})
    @item.status = Item::STATUS_ABUSED
    if !@item.save
      render :json=>{:ok=>false, :error_message=>"an error has occur."}
      return
    end
    
    flag_admin_record = FlagAdminRecord.new()
    flag_admin_record.item_id = @item.id
    flag_admin_record.facebook_id = $facebook.facebook_id
    flag_admin_record.created_date = Time.now
    flag_admin_record.action = FlagAdminRecord::FLAG_ACTION_ABUSE
    flag_admin_record.save
    
    render :json=>{:ok=>true}
  end
  def not_abuse
    @item = Item.first(:conditions=>{:id=> params[:item_id]})
    @item.flags = 0
    if !@item.save
      render :json=>{:ok=>false, :error_message=>"an error has occur."}
      return
    end
    
    item_flag = Flag.all(:conditions=>{:item_id=> @item.id})
    item_flag.each do |flag|
      flag.destroy
    end
    
    flag_admin_record = FlagAdminRecord.new()
    flag_admin_record.item_id = @item.id
    flag_admin_record.facebook_id = $facebook.facebook_id
    flag_admin_record.created_date = Time.now
    flag_admin_record.action = FlagAdminRecord::FLAG_ACTION_NOT_ABUSE
    flag_admin_record.save
    
    render :json=>{:ok=>true}
  end
end
