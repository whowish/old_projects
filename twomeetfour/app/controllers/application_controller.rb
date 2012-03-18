class ApplicationController < ActionController::Base
  include ApplicationHelper
 
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  layout :select_layout
  
  before_filter :common_header, :generate_home_url, :check_login , :check_whowish_word, :set_timezone, :choose_locale
  
  private
  def choose_locale
    @locale = "en"
    whowish_word.set_locale(@locale)
  end
  
  def generate_home_url
    
    @home_url = "/"
    
    if params[:lat]
      @home_url = "/home/#{params[:lat]}/#{params[:lng]}"
    end
    
  end

  def set_timezone
    Time.zone = 'Bangkok'  
  end
  
  def select_layout
    return (request.xhr?) ? "blank":"application"
  end
  
  def check_whowish_word
    whowish_word.activate_edit_mode if session[:whowish_word] == "yes"
  end
  
  def common_header
    response.headers["Connection"] = "close";
    response.headers['P3P'] = 'policyref="/w3c/p3p.xml", CP="NOI COR PSA OUR IND OTC"'
  end
 
  def check_login
    @member = Member.get_member_from_session(session, cookies)
  end
end
