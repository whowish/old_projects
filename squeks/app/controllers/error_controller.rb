class ErrorController < ApplicationController
  
  
  def index
    entity = ErrorLog.new
    entity.identifier = "#{params[:identifier]}"
    entity.description = "#{params[:description]}"
    entity.time = Time.now
    
    begin
      entity.ip_address = request.remote_ip
    rescue Exception=>e
      entity.ip_address = "Unknown"
    end
    
    if entity.save
      render :json=>{:ok=>true}
    else
      render :json=>{:ok=>false}
    end
  end
  
end
