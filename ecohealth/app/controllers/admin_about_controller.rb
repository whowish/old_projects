class AdminAboutController < AdminController
  def save
    about_us = About.first()
    if !about_us
      about_us = About.new()
    end
    
    about_us.description = params[:desc]
    about_us.save
    render :json=>{:ok=>true}
  end
end
