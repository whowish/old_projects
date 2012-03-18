require 'app/helpers/thumbnailism_helper'
require 'app/controllers/thumbnail_controller'
require 'app/controllers/temporary_image_controller'
require 'app/models/temporary_image'
require 'image_helper'
require 'foundation'

begin
    ActiveRecord::Schema.define do
      create_table "temporary_images", :force => false do |t|
        t.string   "name",         :null => false
        t.datetime "created_date", :null => false
      end
    end
rescue
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
  map.connect 'thumbnail/:size/:file', :controller=>"thumbnail", 
                                        :action=>"index", 
                                        :size=>/[0-9]{1,4}x[0-9]{1,4}/, 
                                        :file=>/.+/
                                        
  map.connect 'temporary_image/:action', :controller => 'temporary_image'
end