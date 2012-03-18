begin 
  ActiveRecord::Schema.define do

    create_table :traces, :force => false do |t|
      t.string "facebook_id", :null => false
      t.text "params", :null => false
      t.string "ip_address", :null => false
      t.string "controller_name", :null => false
      t.string "action_name", :null => false
      t.string "result", :null => false
      t.string "browser"
      t.text "referer"
      t.datetime "accessed_date", :null => false
    end
  end
rescue
  #do nothing
end

# extend Rails
require 'app/models/trace'
require 'app/controllers/trace_viewer_controller'

ActionController::Base.append_view_path(RAILS_ROOT+"/vendor/plugins/whowish_foundation/lib/app/views")

%w{ models controllers helpers }.each do |dir|
  path = File.join(File.dirname(__FILE__), 'app', dir)
  $LOAD_PATH.insert(0, path)
  ActiveSupport::Dependencies.load_paths.insert(0, path)
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end


ActionController::Routing::Routes.draw do |map|
  map.connect 'trace_viewer/:action', :controller => 'trace_viewer'
end