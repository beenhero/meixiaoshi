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
  
  # Restful Authentication Resources
  map.resources :services, :member => { :schedules => :any }
  map.resources :passwords
  map.resource :session
  
  map.tag '/tag/:id', :controller => 'services', :action => 'tag'
  
  #admin routes
  map.namespace(:admin) do |admin|
    admin.resources :services, 
      :collection => {:pending => :get, :passive => :get, :suspended => :get, :deleted => :get},
      :member => {:approve => :any, :deny => :any, :suspend => :any, :unsuspend => :any}
    admin.resources :users
  end
  map.admin '/admin', :controller => 'admin/abstract', :action => 'dashboard'
  
  # Home Page
  map.root :controller => 'services', :action => 'index'

  map.resources :users, :member_path => '/:id', :nested_member_path => '/:user_id',
                :member => { :edit_password => :any, :edit_info => :any, :edit_contacts => :any, :calendar => :get, :dashboard => :any, :services => :get }
                
  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
