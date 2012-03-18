# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Foundation
    
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  layout :select_layout
  
  def select_layout
    if request.xhr?
      "blank"
    else
      "main"
    end
  end
  
  before_filter :all_filters
  
  def check_login
    $member = Member.get_guest and return if !session[:member_id]
    
    member = Member.first(:conditions=>{:id=>session[:member_id]})
    
    $member = Member.get_guest and return if !member
    $member = member
  end
  
  def all_filters
    $whowish_word_admin = session[:whowish_word_admin]  
    
     response.headers["Connection"] = "close";
     response.headers['P3P'] = 'policyref="/w3c/p3p.xml", CP="'+COMPACT_POLICY+'"'
     
     check_login
     logger.debug {"member=#{$member.inspect}"}
     
     session[:unique_identifier_key] = rand().to_s if !session[:unique_identifier_key]
     
#     trace = Trace.new(:params => params.inspect,
#                      :accessed_date=>Time.now,
#                      :controller_name=>params[:controller],
#                      :action_name=>params[:action],
#                      :facebook_id=>"",
#                      :result=>"",
#                      :browser=>"",
#                      :referer=>"")
#                      
#      trace.referer = request.env["HTTP_REFERER"] if request.env["HTTP_REFERER"]
#      trace.browser = request.user_agent if request.user_agent
#
#      trace.ip_address = (request.remote_ip + "-"+session[:unique_identifier_key] \
#                          rescue "Unknown-"+session[:unique_identifier_key])
#      
#      trace.save
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
end
