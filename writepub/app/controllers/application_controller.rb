class ApplicationController < ActionController::Base
  include ApplicationHelper
  protect_from_forgery
  
  layout "application"
  
  before_filter :activate_whowish_word, :general_filter, :strip_all_params
  
  def activate_whowish_word
    if params[:edit_mode] == "yes"
      activate_whowish_word_edit_mode
    end
  end
  
  def check_login
    $member = Member.get_member_from_cookies(session,cookies)
  end
  
  def format_error(error_obj)
    
    errors = {}
    
    error_obj.each { |attr,err_msg|
      if !errors[attr]
        errors[attr] = [err_msg]
      else
        errors[attr].push(err_msg)
      end
    }
    
    return errors
  end
  
  def format_single_error(error_obj)
    
    return [] if error_obj == nil
    
    errors = []
    
    error_obj.each { |err_msg|
      errors.push(err_msg)
    }
    
    return errors
  end
  
  private
  def general_filter
    $whowish_word_admin = session[:whowish_word_admin] 
    check_login
  end
  
end
