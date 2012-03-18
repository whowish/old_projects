ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index_bak.html.
#  map.root :controller => "home",:action=>"landing"
#
#  # See how all your routes lay out with "rake routes"
#
#  # Install the default routes as the lowest priority.
#  # Note: These default routes make all actions in every controller accessible via GET requests. You should
#  # consider removing or commenting them out if you're using named routes and resources.
#  map.connect 'home/landing', :controller => "home",:action=>"landing"
#  map.connect 'home/too_few_friends', :controller => "home",:action=>"too_few_friends"
#  map.connect 'home/:figure_query', :controller=>'home', :figure_query=>/.+/
#  map.connect 'figure/share_after_add/:figure_id/:share_unique_key', :controller=>'figure', :action=>"share_after_add", :figure_id=>/[0-9]+/, :share_unique_key=>/[a-zA-Z0-9]+/
#  map.connect 'comment/share_after_allow/:comment_id/:share_unique_key', :controller=>'comment', :action=>"share_after_allow", :figure_id=>/[0-9]+/, :share_unique_key=>/[a-zA-Z0-9]+/
#  map.connect 'comment/view/:comment_id', :controller=>'comment', :action=>"view", :comment_id=>/[0-9]+/
#  map.connect 'discussion/view/:discussion_id', :controller=>'discussion', :action=>"view", :discussion_id=>/[0-9]+/
#  map.connect 'discussion/share_after_allow/:comment_id/:share_unique_key', :controller=>'discussion', :action=>"share_after_allow", :comment_id=>/[0-9]+/, :share_unique_key=>/[a-zA-Z0-9]+/
#  map.connect 'discussion/share_discussion_after_add/:discussion_id/:share_unique_key', :controller=>'discussion', :action=>"share_discussion_after_add", :discussion_id=>/[0-9]+/, :share_unique_key=>/[a-zA-Z0-9]+/
#  map.connect 'comment_pending/:unique_key', :controller=>'comment_pending', :action=>"index", :discussion_id=>/[0-9A-Za-z]+/
#  map.connect 'figure_love_pending/:unique_key', :controller=>'figure_love_pending', :action=>"index", :discussion_id=>/[0-9A-Za-z]+/
#  map.connect 'discussion_love_pending/:unique_key', :controller=>'discussion_love_pending', :action=>"index", :discussion_id=>/[0-9A-Za-z]+/
#  map.connect 'discussion_pending/:unique_key', :controller=>'discussion_pending', :action=>"index"
#  map.connect 'discussion/add/:figure_id', :controller=>'discussion', :action=>"index"
#  
#  map.connect ':controller/:action/:id'
#  map.connect ':controller/:action/:id.:format'
  
end
