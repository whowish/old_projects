# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include FacebookHelper
  include TraceViewerHelper
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
  
  before_filter :facebook_connect_or_app,:all_filters,:redirect_if_code, :choose_locale
  
  private
  def facebook_connect_or_app
    if params[:signed_request]
      logger.debug {"signed_request=#{params[:signed_request]}"}
      decode_signed_request
      @redirect_url = "http://#{DOMAIN_NAME}"
      render "redirect/index", :layout=>"blank"
    else
      facebook_connect
    end

  end

  private
  def redirect_if_code
    # prevent security because user might send URL with params[:code] to other people
    if params[:code]

      params[:retry] ||= 0
      params[:retry] = params[:retry].to_i + 1

      if $facebook.is_guest and params[:retry] < 10
        redirect_to "http://#{DOMAIN_NAME}#{request.path}?code=#{params[:code]}&retry=#{params[:retry]}"
      end


    end
  end
  
  def all_filters
    
    $whowish_word_admin = session[:whowish_word_admin]
    response.headers["Connection"] = "close";
    
    $is_first_time = true
    
    if session[:unique_identifier_key]
      $is_first_time = false
    end

    session[:unique_identifier_key] = rand().to_s if !session[:unique_identifier_key]
    
    
    
    response.headers['P3P'] = 'policyref="/w3c/p3p.xml", CP="'+COMPACT_POLICY+'"'
    
    
    
    session[:country_code] = "US"#(locateIp(request.remote_ip,true) rescue "US") if !session[:country_code]
    
    if params[:test_country_code]
      session[:country_code] = params[:test_country_code]
    end
    
    $facebook.country_code = session[:country_code]
    
#    if $is_first_time == true and $facebook.is_guest
#      render "home/landing",:layout=>"blank"
#      return
#    end
    
    
    
    college = College.first(:conditions=>{:id=>$facebook.college_id})
    
    $facebook.country_code = college.country_code if college
    
    params[:whowish_locale] = $facebook.country_code
    
#    if request.cookies["_session_id"].to_s.blank?
#      render "facebook_error/cookies_disabled",:layout=>"blank"
#      return
#    end
        
#    if !params[:signed_request]
#      @redirect_url = "http://apps.facebook.com/"+FACEBOOK_APP_NAME
#      render "redirect/index", :layout=>"blank"
#      return
#    end
    
    check_flagged_items

    if params[:controller] == "home" and params[:action] == "load_more"
      
    else
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
      trace.decoded_signed_request = ""

      begin
        trace.ip_address = request.remote_ip + "-"+session[:unique_identifier_key]
      rescue
        trace.ip_address = "Unknown-"+session[:unique_identifier_key]
      end
      
      trace.save
    end
    
    
  end
  
  def check_flagged_items
    if !session[:flagged_item_ids] and $facebook and $facebook.facebook_id
      
      flag_ids = []
      
      flags = Flag.all(:conditions=>{:facebook_id=>$facebook.facebook_id})
      
      flags.each { |f|
        flag_ids.push(f.item_id)
      }
      
      session[:flagged_item_sql] = ""
      if flags.length > 0
        session[:flagged_item_ids] = flag_ids
        session[:flagged_item_sql] = "AND NOT (id in ("+flag_ids.join(",")+"))"
      end
    end
  end
  
#  def check_college
#    if params[:controller] == "home" and $facebook.college_id == 0
#      print "redirect"
#      redirect_to :controller=>"college",:action=>"show_dialog"
#      return
#    end
#  end
  
  def check_aesir
    if !$facebook or !$facebook.facebook_id or $facebook.is_aesir != 1
      redirect_to "/"
      return
    end
  end
  

  

end
