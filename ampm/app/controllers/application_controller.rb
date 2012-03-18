# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include FacebookHelper
  helper :all # include all helpers, all the time
  #protect_from_forgery # See ActionController::RequestForgeryProtection for details

  layout :select_layout
  
  def select_layout
    if request.xhr?
      "blank"
    else
      "main"
    end
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  before_filter :all_filters
  
  def all_filters
  
    $whowish_word_admin = session[:whowish_word_admin]
    response.headers["Connection"] = "close";
    
    $is_first_time = true
    
    if session[:unique_identifier_key]
      $is_first_time = false
    end
    
    session[:unique_identifier_key] = rand().to_s if !session[:unique_identifier_key]

    response.headers['P3P'] = 'policyref="/w3c/p3p.xml", CP="'+COMPACT_POLICY+'"'
    
    decoded_data = decode_signed_request()
    
    trace = Trace.new(:params => params.inspect,
                      :accessed_date=>Time.now,
                      :controller_name=>params[:controller],
                      :action_name=>params[:action],
                      :result=>"ok",
                      :facebook_id=>"Unknown",
                      :browser=>"",
                      :decoded_signed_request=>"",
                      :referer=>"")
                      
      trace.referer = request.env["HTTP_REFERER"] if request.env["HTTP_REFERER"]
      trace.facebook_id = $facebook.facebook_id if $facebook and $facebook.facebook_id
      trace.browser = request.user_agent if request.user_agent
      trace.decoded_signed_request = decoded_data.inspect if decoded_data

      begin
        trace.ip_address = request.remote_ip + "-"+session[:unique_identifier_key]
      rescue
        trace.ip_address = "Unknown-"+session[:unique_identifier_key]
      end
      
      trace.save
      
      if $facebook.is_guest and params[:controller] != "misc"
        
        if params[:event_id]
          render "home/landing_for_event_response", :layout=>"landing"
        else
          render "home/landing", :layout=>"landing"
        end
        
#        @redirect_url = generate_permission_url([],"http://apps.facebook.com/"+FACEBOOK_APP_NAME+request.path+"?"+request.env['QUERY_STRING'])
#        render "redirect/index", :layout=>"blank"
        return
      end
  end
  
  

end
