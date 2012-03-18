require 'app/helpers/web_metrics_swiper'

## define schema for words
begin 
  ActiveRecord::Schema.define do
  
    create_table "web_traces", :force => false do |t|
      t.string "ip_address", :null => false
      t.string "unique_key", :null => false
      t.datetime "time", :null => false
      t.decimal "fraction_time", :precision => 17, :scale => 6
      t.string "controller", :null => false
      t.string "action", :null => false
      t.string "browser", :null => false
      t.string "member_id", :null => false
      t.string "referer", :null => false
    end

  end

  add_index :web_traces, :unique_key
rescue
  #do nothing
end

begin 
  ActiveRecord::Schema.define do

    create_table "web_trace_unique_user_hours", :force => false do |t|
      t.date "date", :null => false
      t.integer "hour", :null => false
      t.integer "unique_user_count",:null=>false,:default=>0
      t.integer "unique_ip_count",:null=>false,:default=>0
      t.integer "unique_member_count",:null=>false,:default=>0
    end

  end

rescue
  #do nothing
end

begin 
  ActiveRecord::Schema.define do

    create_table "web_trace_unique_user_days", :force => false do |t|
      t.date "date", :null => false
      t.integer "unique_user_count",:null=>false,:default=>0
      t.integer "unique_ip_count",:null=>false,:default=>0
      t.integer "unique_member_count",:null=>false,:default=>0
    end

  end

rescue
  #do nothing
end

begin 
  ActiveRecord::Schema.define do

    create_table "web_trace_unique_user_weeks", :force => false do |t|
      t.date "date", :null => false
      t.integer "unique_user_count",:null=>false,:default=>0
      t.integer "unique_ip_count",:null=>false,:default=>0
      t.integer "unique_member_count",:null=>false,:default=>0
    end

  end

rescue
  #do nothing
end

begin 
  ActiveRecord::Schema.define do

    create_table "web_trace_unique_user_months", :force => false do |t|
      t.date "date", :null => false
      t.integer "unique_user_count",:null=>false,:default=>0
      t.integer "unique_ip_count",:null=>false,:default=>0
      t.integer "unique_member_count",:null=>false,:default=>0
    end

  end

rescue
  #do nothing
end

begin 
#  ActiveRecord::Schema.define do
#    create_table "web_trace_retentions", :force => false do |t|
#      t.datetime "time", :null => false
#      t.integer "new_user_count",:null=>false,:default=>0
#      t.integer "old_user_count",:null=>false,:default=>0
#    end
#    
#    create_table "web_trace_retention_member_ids", :force => false do |t|
#      t.datetime "time", :null => false
#      t.string "member_id",:null=>false
#    end
#    
#  end

rescue
  #do nothing
end

begin 
  ActiveRecord::Schema.define do

    create_table "web_metrics_activities", :force => false do |t|
      t.string "controller"
      t.string "action"
      t.string "action_type"
    end

  end

rescue
  #do nothing
end

begin 
  ActiveRecord::Schema.define do

    create_table "web_trace_activity_hours", :force => false do |t|
      t.date "date", :null => false
      t.integer "hour", :null => false
      t.string "controller"
      t.string "action"
      t.integer "guest_activity_count"
      t.integer "member_activity_count"
      t.integer "guest_count"
      t.integer "member_count"
    end

  end

rescue
  #do nothing
end

class ActionController::Base
  
  def web_metrics_tracing(member_id)
    
    trace = WebTrace.new
    trace.controller = params[:controller] || ""
    trace.action = params[:action] || ""
    trace.time = Time.now
    trace.fraction_time = trace.time.to_f
    trace.browser = request.user_agent || ""
    trace.member_id = member_id || ""
    trace.unique_key = session[:web_trace_unique_key]
    trace.ip_address = request.remote_ip || ""
    trace.referer = request.env["HTTP_REFERER"] || ""
    trace.save
    
    session[:web_trace_unique_key] = trace.unique_key
    
    activity = WebMetricsActivity.first(:conditions=>{:controller=>params[:controller],:action=>params[:action]})

    if !activity
      WebMetricsActivity.create(:controller=>params[:controller],:action=>params[:action],:action_type=>WebMetricsActivity::ACTION_TYPE_VIEW)
    end
  end
  
end

# load all controllers, helpers, and models
%w{ models controllers helpers }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH.insert(0, path)
  ActiveSupport::Dependencies.load_paths.insert(0, path)
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

ActionController::Base.append_view_path(RAILS_ROOT+"/vendor/plugins/whowish_foundation/lib/app/views")

# add routes
class << ActionController::Routing::Routes;self;end.class_eval do
  define_method :clear!, lambda {}
end

ActionController::Routing::Routes.draw do |map|
  map.connect 'web_metrics/swipe_data', :controller => 'web_metrics', :action=>'swipe_data'
  map.connect 'web_metrics/change_type', :controller => 'web_metrics', :action=>'change_type'
end