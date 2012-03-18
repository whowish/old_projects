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
  
  def check_admin
    if !$facebook.is_aesir
      render "valhalla/please_login"
      return
    end
  end
  

  before_filter :share_logging,:general_before_filter, :facebook_connect_or_app, :set_global_vars, :redirect_if_code, :check_friends, :choose_locale

  private
  def share_logging
    redirect_to "/"
    if params[:share_log]
      ShareLog.create(:share_type=>params[:share_log],:facebook_id=>params[:share_log_referer_id],:created_date=>Time.now)
    end
  end

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
    $is_anonymous = false
    $is_anonymous = true if params[:is_anonymous] == "yes"

    if $facebook.is_guest
      $member = Member.new

    else
      $member = Member.first(:conditions=>{:facebook_id=>$facebook.facebook_id})
      $member = Member.new(:facebook_id=>$facebook.facebook_id,
                            :anonymous_profile_pic=>"",
                            :updated_date=>Time.now) if !$member

    end

    $member.set_facebook_cache($facebook)
    $facebook = $member
    
    web_metrics_tracing($facebook.facebook_id)
    
    if !$facebook.is_guest and ($member.anonymous_profile_pic == "" or ((Time.now-$member.updated_date) > (60*60*24)))
        Delayed::Job.enqueue MosaicGenerator.new($member.facebook_id,$member.profile_picture_url)
    end

    session[:country_code] = "US"#(locateIp(request.remote_ip,true) rescue "US") if !session[:country_code]
    session[:country_code] = session[:country_code].upcase

    if params[:country_code]
      session[:country_code] = params[:country_code].upcase
    end
    
    session[:whowish_locale] = session[:country_code].downcase
    params[:whowish_locale] = session[:country_code].downcase
      

    $facebook.country_code = session[:country_code]

    logger.debug {"CountryCode=#{$facebook.country_code}"}
    
    begin
      language = Language.first(:conditions=>{:code=>$facebook.country_code})
      
      $facebook.country_code = "US" if !language
    rescue
      $facebook.country_code = "US"
    end

  end

  private
  def redirect_if_code
    # prevent security because user might send URL with params[:code] to other people
    if params[:code]

      params[:retry] ||= 0
      params[:retry] = params[:retry].to_i + 1

      if $facebook.is_guest and params[:retry] < 10
        
        q_string = []
        params.each_pair { |k,v|
          next if k.to_s == "controller"
          next if k.to_s == "action"
          q_string.push("#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}")
        }
        
        redirect_to "http://#{DOMAIN_NAME}#{request.path}?#{q_string.join("&")}"
      else 
        
        q_string = []
        params.each_pair { |k,v|
          next if k.to_s == "code"
          next if k.to_s == "controller"
          next if k.to_s == "action"
          q_string.push("#{CGI.escape(k.to_s)}=#{CGI.escape(v.to_s)}")
        }
        
        redirect_to "http://#{DOMAIN_NAME}#{request.path}?#{q_string.join("&")}"
        
      end

    end
  end

  private
  def check_friends

    logger.debug { "Enter check_friends()" }
    logger.debug { "controller=#{params[:controller]},action=#{params[:action]},is_guest=#{$member.is_guest},friend_length=#{$member.all_friends.length}" }

    action_id = "#{params[:controller]}/#{params[:action]}"
    if !["logout/index"].include?(action_id)

      if !$member.is_guest and $member.all_friends.length < THRESHOLD_FRIENDS and !$member.is_aesir
        if request.xhr?
          render :json=>{:ok=>false,:error_message=>TOO_FEW_FRIENDS_ERROR}
        else
          session[:access_token] = nil
          session[:facebook_data] = nil
          redirect_to "/home/too_few_friends"
        end
      end
    end

    logger.debug { "Exit check_friends()" }
  end

end
