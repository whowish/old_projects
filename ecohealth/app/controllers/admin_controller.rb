class AdminController < ActionController::Base
  
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  layout "admin_layout"
  
  before_filter :check_whowish_word
  before_filter :check_member, :except=>[:do_login,:login]
  
  def check_whowish_word
    $whowish_word_admin = session[:whowish_word_admin]  
  end
  
  def check_member
    render "admin/login", :layout=>"blank" if session[:ecohealth_admin] != "sawasdee"
    
  end
  
  def do_login
    if params[:password] == "ecohealth#123"
      session[:ecohealth_admin] = "sawasdee"
      index
      render "admin/index"
    else
      @error = "The password is invalid."
      render "admin/login", :layout=>"blank"
    end
  end
  
  def logout
    session[:ecohealth_admin] = nil
    render "admin/login", :layout=>"blank"
  end
  
  def index
    
  end
end
