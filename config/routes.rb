ActionController::Routing::Routes.draw do |map|
  
  
  # Restful Authentication Rewrites
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => nil
  map.forgot_password '/forgot_password', :controller => 'passwords', :action => 'new'
  map.change_password '/change_password/:reset_code', :controller => 'passwords', :action => 'reset'
  map.open_id_complete '/opensession', :controller => "sessions", :action => "create", :requirements => { :method => :get }
  map.open_id_create '/opencreate', :controller => "users", :action => "create", :requirements => { :method => :get }
  
  map.resources :passwords
  map.resource :session
  
  map.resources :services, :member => { :schedules => :any }
  map.resources :orders, :member => { :replied => :any }
  map.resources :tags
  
  map.fetch_cities '/addresses/fetch_cities', :controller => 'addresses', :action => 'fetch_cities'
  map.fetch_counties '/addresses/fetch_counties', :controller => 'addresses', :action => 'fetch_counties'
  map.fetch_areas '/addresses/fetch_areas', :controller => 'addresses', :action => 'fetch_areas'
  
  map.tag '/tag/:id', :controller => 'services', :action => 'tag'
  
  #admin routes
  map.namespace(:admin) do |admin|
    admin.resources :services, 
      :collection => {:pending => :get, :passive => :get, :suspended => :get, :deleted => :get},
      :member => {:approve => :any, :deny => :any, :suspend => :any, :unsuspend => :any}
    admin.resources :users, :collection => {:pending => :get, :deleted => :get}, :member => { :edit_password => :any, :edit_info => :any, :edit_contacts => :any, :renew => :any }
    admin.resources :orders, :collection => {:deleted => :get, :delayed => :get}
  end
  map.admin '/admin', :controller => 'admin/abstract', :action => 'dashboard'
  
  # Home Page
  map.root :controller => 'services', :action => 'index'

  map.resources :users, :member_path => '/:id', :nested_member_path => '/:user_id',
                :member => { :edit_password => :any, :edit_info => :any, :edit_contacts => :any, :calendar => :get, :dashboard => :any, :services => :get, :orders => :get }
                
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
