# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include FacebookHelper
  include ApplicationHelper
  include TraceViewerHelper
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  skip_before_filter :verify_authenticity_token, :if=>:check_signed_request

  def check_signed_request
    return params[:signed_request]
  end

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
  
  before_filter :choose_locale, :general_before_filter, :facebook_connect_or_app, :set_global_vars, :trace_logger, :redirect_if_code

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
  def general_before_filter

    $whowish_word_admin = session[:whowish_word_admin]
    response.headers["Connection"] = "close"

    $is_first_time = true

    if session[:unique_identifier_key]
      $is_first_time = false
    end

    session[:unique_identifier_key] = rand().to_s if !session[:unique_identifier_key]

    response.headers['P3P'] = 'policyref="/w3c/p3p.xml", CP="'+COMPACT_POLICY+'"'


  end

  private
  def set_global_vars
   
    if $facebook.is_guest
      $member = Member.new

    else
      $member = Member.first(:conditions=>{:facebook_id=>$facebook.facebook_id})
      $member = Member.new(:facebook_id=>$facebook.facebook_id,
                            :updated_date=>Time.now) if !$member

    end

    $member.set_facebook_cache($facebook)
    $facebook = $member

  end

  private
  def redirect_if_code
    # prevent security because user might send URL with params[:code] to other people
    if params[:code]

      params[:retry] ||= 0
      params[:retry] = params[:retry].to_i + 1

      if $facebook.is_guest and params[:retry] < 10
        redirect_to "http://#{DOMAIN_NAME}#{request.path}?code=#{params[:code]}&retry=#{params[:retry]}"
      else
        redirect_to "http://#{DOMAIN_NAME}#{request.path}"
      end


    end
  end
 

  private
  def trace_logger
    trace = Trace.new(:params => params.inspect,
                      :accessed_date=>Time.now,
                      :controller_name=>params[:controller],
                      :action_name=>params[:action],
                      :result=>"ok",
                      :facebook_id=>"Unknown",
                      :browser=>"",
                      :referer=>"")

      trace.referer = request.env["HTTP_REFERER"] if request.env["HTTP_REFERER"]
      trace.facebook_id = $facebook.facebook_id if $facebook and $facebook.facebook_id
      trace.browser = request.user_agent if request.user_agent

      begin
        trace.ip_address = request.remote_ip + "-"+session[:unique_identifier_key]
      rescue
        trace.ip_address = "Unknown-"+session[:unique_identifier_key]
      end

      trace.save
  end
end
