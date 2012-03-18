
require 'app/controllers/redirect_controller'

# load all controllers, helpers, and models
%w{ controllers }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH.insert(0, path)
  ActiveSupport::Dependencies.load_paths.insert(0, path)
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end

ActionController::Base.append_view_path(RAILS_ROOT+"/vendor/plugins/whowish_foundation/lib/app/views")

ActionController::Routing::Routes.draw do |map|
  map.connect 'redirect/:action', :controller => 'redirect'
  map.connect 'facebook_error/:action', :controller => 'facebook_error'
end 
begin
  ActiveRecord::Schema.define do
    create_table "facebook_caches", :force => false do |t|
      t.string   "name",         :null => false
      t.string   "gender"
      t.datetime "updated_date", :null => false
      t.column   "facebook_id",  'bigint'
      t.string   "college"
      t.string   "email"
    end
  
    add_index "facebook_caches", ["facebook_id"], :name => "facebook_id", :unique => true
  end
rescue
end

begin
  ActiveRecord::Schema.define do
    create_table "facebook_friend_caches", :force => false do |t|
      t.column   "facebook_id",  'bigint'
      t.interger "friend_count", :default=>0
      t.text     "friends",      :null => false
      t.text     "friends_of_friends",      :null => false
      t.datetime "updated_date", :null => false
    end
  
    add_index "facebook_friend_caches", ["facebook_id"], :name => "facebook_id", :unique => true
  end
rescue
end

require 'facebook_helper'
require 'facebook_cache'
require 'facebook_friend_cache'
require 'async_facebook_friend_cache'
require 'async_facebook_cache'