ActionController::Routing::Routes.draw do |map|
  map.resources :smerf_forms

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

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect 'programme_items/list', :controller => 'programme_items', :action => 'list'
  map.resources :programme_items
  map.resources :registrationDetails, :has_one => :participant
  map.resources :postal_addresses, :has_many => :people
  map.resources :email_addresses, :has_many => :people
  map.resources :menus
  
  map.connect 'participants/import', :controller => 'people', :action => 'import'
  map.connect 'participants/doimport', :controller => 'people', :action => 'doimport', :method => 'post'
    
  map.resources :people, :as => "participants", 
    :has_many => [:addresses, :postalAddresses, :emailAddresses],
    :has_one => :registrationDetail,
    :collection => {:list => :get }
  map.resources :people, :as => "participants" do |person|
    person.resource :tags, :member => {:remove => :delete, :add => :post, :index => :get, :list => :get}, :controller => 'people/tags',
      :except => [:destroy, :new, :update, :create, :edit]
  end

  map.connect 'participants/tags/list', :controller => 'people/tags', :action => 'list'
  map.connect 'participants/tags/index', :controller => 'people/tags', :action => 'index'

  map.connect 'participants/list', :controller => 'people', :action => 'list'
 
  map.resources :rooms

  map.resource :user_session
  map.root :controller => "user_sessions", :action => "new"
  map.login "login", :controller => "user_sessions", :action => "new"
  map.logout "logout", :controller => "user_sessions", :action => "destroy"

  map.resource :account, :controller => "users"
  map.resources :users
    
  #
#  map.resource :survey_session
#  map.root :controller => "survey_sessions", :action => "new" # optional, this just sets the root route

  map.resources :survey_respondent_sessions # just for the new session...

  map.resources :survey_respondents

end
