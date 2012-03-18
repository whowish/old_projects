Writepub::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => "home#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  
  match 'facebook_registration/create', :to=>"facebook_registration#create"
  match 'facebook_registration/thank_you', :to=>"facebook_registration#thank_you"
  match 'facebook_registration/receiver_kratoo', :to=>"facebook_registration#receiver_kratoo"
  match 'facebook_registration/receiver_reply', :to=>"facebook_registration#receiver_reply"
  match 'facebook_registration/:redirect_path', :to=>"facebook_registration#index", :constraints => { :redirect_path => /.*/ }
  
  match 'kratoo/list(/:sort(.:page)(/:tag))', :to=>"kratoo#list"
  
  match 'profile/index/:member_id', :to=>"profile#index"
  match 'profile/info/:member_id', :to=>"profile#info"
  match 'profile/_:member_id', :to=>"profile#index"
  
  match ':controller(/:action(/:id(.:format)))'
  
  mount Resque::Server.new, :at => "/resque"
  
end
