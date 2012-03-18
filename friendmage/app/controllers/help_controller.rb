class HelpController < ApplicationController
  def send_contact_us
    from_name = "guest"
    from_name = $facebook.name if !$facebook.is_guest
    UserMailer.send_later(:deliver_contact_us,$facebook.name,params[:from_mail],params[:topic],params[:content])
    render :json=>{:ok=>true,:html=>(render_to_string :partial=>"help/send_successfully")}
  end
end
