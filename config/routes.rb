ActionController::Routing::Routes.draw do |map|

  map.resources :publisher, :member => {:index => :get, :publish => :post, :list => :get},
      :except => [:destroy, :new, :create, :edit, :show, :update]

  map.connect 'tags/list.:format', :controller => 'tags', :action => 'list'
  map.resources :tags, :member => {:remove => :get, :add => :post, :index => :get, :edit => :get},
      :except => [:destroy, :new, :create]

  map.resources :tag_contexts

  map.resources :survey_copy_statuses

  map.resources :smerf_forms

  map.resources :monitor, :only => :index # we only need the one method/route for this

  map.resources :item_planner, :only => :index # TODO - check

  map.connect 'program_planner/list', :controller => 'program_planner', :action => 'list', :method => 'post'
  map.connect 'program_planner/addItem', :controller => 'program_planner', :action => 'addItem', :method => 'post'
  map.connect 'program_planner/removeItem', :controller => 'program_planner', :action => 'removeItem', :method => 'get'
  map.connect 'program_planner/getConflicts', :controller => 'program_planner', :action => 'getConflicts', :method => 'get'
  map.connect 'program_planner/getRoomControl', :controller => 'program_planner', :action => 'getRoomControl', :method => 'get'
  map.resources :program_planner, :member => {:index => :get, :edit => :get}

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
  map.resources :programme_items, :member => {:updateParticipants => :post}
  map.resources :programme_items

  map.resources :registrationDetails, :has_one => :person
 
  map.connect 'edited_bios/exportbiolist', :controller => 'edited_bios',:action => 'exportbiolist'
  map.connect 'edited_bios/selectExportBioList', :controller => 'edited_bios',:action => 'selectExportBioList'
  map.resources :edited_bios, :has_one => :person

  map.resources :available_dates, :has_one => :person

  map.resources :postal_addresses, :has_many => :people
  map.resources :email_addresses, :has_many => :people
  map.resources :phone_numbers, :has_many => :people
  map.resources :menus
  
  map.connect 'participants/ReportInviteStatus', :controller => 'people', :action => 'ReportInviteStatus'
  map.connect 'participants/doReportInviteStatus', :controller => 'people', :action => 'doReportInviteStatus'
  map.connect 'participants/exportemailxml', :controller => 'people', :action => 'exportemailxml'
  map.connect 'participants/doexportemailxml', :controller => 'people', :action => 'doexportemailxml', :method => 'post'
  map.connect 'participants/doSetInvitePendingToInvited', :controller => 'people', :action => 'doSetInvitePendingToInvited', :method => 'post'
  map.connect 'participants/SetInvitePendingToInvited', :controller => 'people', :action => 'SetInvitePendingToInvited'
  map.connect 'participants/invitestatuslist', :controller => 'people', :action => 'invitestatuslist'
  map.connect 'participants/invitestatuslistwithblank', :controller => 'people', :action => 'invitestatuslistwithblank'
  map.connect 'participants/acceptancestatuslist', :controller => 'people', :action => 'acceptancestatuslist'
  map.connect 'participants/acceptancestatuslistwithblank', :controller => 'people', :action => 'acceptancestatuslistwithblank'
  map.connect 'participants/updateExcludedTimesFromSurveys',:controller => 'people', :action => 'updateExcludedTimesFromSurveys', :method => 'post'

  map.resources :people, :as => "participants", 
    :has_many => [:addresses, :postalAddresses, :emailAddresses, :phoneNumbers, :availabilities, :programme_items],
    :has_one => [:registrationDetail, :edited_bio, :available_date],
    :collection => {:list => :get },
    :member => {:show => :get}

  map.resources :programme_items,
    :has_many => [:excluded_items_survey_maps,:mapped_survey_questions]

  map.connect 'participants/list', :controller => 'people', :action => 'list'
 
  map.connect 'rooms/list', :controller => 'rooms', :action => 'list'
  map.connect 'rooms/listwithblank', :controller => 'rooms', :action => 'listwithblank'
  map.resources :rooms

  map.connect 'venue/list', :controller => 'venue', :action => 'list'
  map.resources :venue

  map.connect 'planner_reports/:action', :controller => 'planner_reports'
  map.resources :planner_reports

  map.connect 'survey_reports/:action', :controller => 'survey_reports'
  map.resources :survey_reports

  map.connect 'invitation_categories/list', :controller => 'invitation_categories', :action => 'list'

  map.resources :invitation_categories
  
  map.connect 'formats/list', :controller => 'formats', :action => 'list'
  map.connect 'formats/listwithblank', :controller => 'formats', :action => 'listwithblank'
  map.resources :formats
  
  map.connect 'pending_import_people/import', :controller => 'pending_import_people', :action => 'import'
  map.connect 'pending_import_people/doimport', :controller => 'pending_import_people', :action => 'doimport', :method => 'post'   
  map.resources :pending_import_people
  
  map.resource :user_session
  map.root :controller => "user_sessions", :action => "new"
  map.login "login", :controller => "user_sessions", :action => "new"
  map.logout "logout", :controller => "user_sessions", :action => "destroy"

  #
  # The new(s) were removed so as to prevent anonymous people creating new accounts
  #
  map.resource :account, :controller => "users", :except => :new
  map.resources :users, :except => :new
  map.connect 'usersadmin/list', :controller => 'users/admin', :action => 'list'
  map.resources :usersadmin, :controller => 'users/admin'

  map.connect 'roles/list', :controller => 'roles', :action => 'list'

  #
  #
  #
  map.resources :survey_respondent_sessions # just for the new session...

  #
  #
  # TODO - check these routes
  map.connect 'survey_respondents/tags_admin', :controller => 'survey_respondents/tags_admin', :action => 'index'
  map.connect 'survey_respondents/tags_admin/update', :controller => 'survey_respondents/tags_admin', :action => 'update', :via => :post
  
  #
  map.connect 'survey_respondents/reviews/list', :controller => 'survey_respondents/reviews', :action => 'list'
  map.namespace :survey_respondents do |respondent|
    respondent.resources :reviews, :member => {:list => :get, :states => :get, :copySurvey => :post }
  end
    
  map.resources :survey_respondents

  # 
  map.resources :survey_respondents do |respondent|
    respondent.resource :tags, :member => {:cloud => :get, :alltags => :get, :list => :get, :update => :post}, 
      :controller => 'survey_respondents/tags',
      :except => [:destroy, :new, :create, :edit, :remove]
  end

  # These also take the context as a parameter...
  map.connect 'survey_respondents/tags/alltags', :controller => 'survey_respondents/tags', :action => 'alltags'
  map.connect 'survey_respondents/tags/cloud', :controller => 'survey_respondents/tags', :action => 'cloud'
  
  # Default routes 
  map.index 'index', :controller => "user_sessions", :action => "new"
  map.root :index 

  map.connect '', :controller => "user_sessions", :action => "new" 
  
  map.resources :excluded_items_survey_maps, :has_many => :programme_items,:has_many => :mapped_survey_questions

  map.connect 'excluded_times/PopulateExcludedTimesMap',:controller => 'excluded_times', :action => 'PopulateExcludedTimesMap', :method => 'post'

  map.resources :excluded_times

end
