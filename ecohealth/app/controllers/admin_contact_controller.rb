class AdminContactController < AdminController
  def save
    contact_us = Contact.first()
    if !contact_us
      contact_us = Contact.new()
    end
    
    contact_us.description = params[:desc]
    contact_us.save
    render :json=>{:ok=>true}
  end
end
