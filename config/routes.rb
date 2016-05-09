Rails.application.routes.draw do

  #
  # The new(s) were removed so as to prevent anonymous people creating new accounts
  #
  devise_for :users, :controllers => { :registrations => "registrations" } #, skip: :sessions
  devise_for :support_users, :controllers => { :registrations => "registrations" } #, skip: :sessions
  
  # Default routes
  authenticated :user do
    root :to => 'pages/home_dash#index', :as => :authenticated_root
  end
  authenticated :support_user do
    root :to => 'pages/home_dash#index', :as => :authenticated_root
  end
  unauthenticated do
    root :to => redirect('/users/sign_in') , :as => :unauthenticated_root # if not authenticated then take the user to the sign in page
  end

  # get "support/index"
  match 'support',                       :controller => 'support', :action => 'index'
  
  #
  # The 'landing' pages for the various parts of the application
  #
  namespace :pages do
    resources :home_dash
    
    match "participants_dash/:cellname" => "participants_dash#index"
    match "items_dash/:cellname" => "items_dash#index"
    match "schedule_dash/:cellname" => "schedule_dash#index"
    match "venues_dash/:cellname" => "venues_dash#index"
    match "surveys_dash/:cellname" => "surveys_dash#index"
    match "communications_dash/:cellname" => "communications_dash#index"
    match "reports_dash/:cellname" => "reports_dash#index"
    match "publications_dash/:cellname" => "publications_dash#index"
    match "admin_dash/:cellname" => "admin_dash#index"
  end

  #
  # Panels are 'pages' that can appear within a dialog
  #
  namespace :panels do
    match "item_mgmt" => "item_mgmt#index"
  end
  
  #
  # For user and user management
  #
  namespace :users do
    match "admin/list" => 'admin#list'
    resources :admin
  end
  match 'roles/list' => 'roles#list'

  #
  # Participant/Attendee management
  #
  match 'participants/merge',                         :controller => 'people', :action => 'merge',            :method => 'post'
  match 'participants/getList',                       :controller => 'people', :action => 'getList',            :method => 'post'
  match 'participants/count',                         :controller => 'people', :action => 'count',              :method => 'get'
  match 'participants/generateInviteKey/:id',         :controller => 'people', :action => 'generateInviteKey',  :method => 'get'
  match 'participants/invitestatuslist',              :controller => 'people', :action => 'invitestatuslist'
  match 'participants/acceptancestatuslist',          :controller => 'people', :action => 'acceptancestatuslist'
  match 'participants/acceptancestatuslistwithblank', :controller => 'people', :action => 'acceptancestatuslistwithblank'
  match 'participants/invitestatuslistwithblank',     :controller => 'people', :action => 'invitestatuslistwithblank'
  resources :people, :path => "participants" do
    resources :addresses, :postalAddresses, :emailAddresses, :phoneNumbers, :availabilities, :programme_items
    resources :registrationDetails do
      get 'show'
    end
    resources :edited_bios, :available_dates, :bio_images
    collection do
      get 'list'
      post 'list'
    end
  end

  #
  # Programme Items
  #
  match 'programme_items/drop',           :controller => 'programme_items', :action => 'drop',                        :method => 'get'
  match 'programme_items/list(/:no_breaks)',           :controller => 'programme_items', :action => 'list',         :defaults => { :format => 'json' }
  match 'programme_items/getList',        :controller => 'programme_items', :action => 'getList',                     :method => 'post'
  match 'programme_items/get_children',   :controller => 'programme_items', :action => 'get_children', :method => 'post', :defaults => { :format => 'json' }

  # TOOD - need a cleaner mechanism to assign the publication reference number and change to match the new mechanisms
  # match 'programme_items/assign_reference_numbers',     :controller => 'programme_items', :action => 'assign_reference_numbers'

  resources :programme_items do
    resources :excluded_items_survey_maps,:mapped_survey_questions,:equipment_needs
    # member do
      # put 'updateParticipants'
    # end
  end
  
  #
  get 'programme_item_assignments/:item_id(/:role_id)', :controller => 'programme_item_assignments', :action => 'index',  :defaults => { :format => 'json' }
  put 'programme_item_assignments/:item_id',            :controller => 'programme_item_assignments', :action => 'update', :defaults => { :format => 'json' }
  
  #
  #
  #
  match '/excluded_items/:id/exclusions', :controller => 'excluded_items', :action => 'exclusions', :via => :put
  resources :excluded_items
  
  #
  #
  #
  namespace :items do
    resources :confict_exceptions
  end
  
  #
  #
  #
  match '/import_mappings/columns' => 'import_mappings#columns'
  resources :import_mappings
  resources :file_uploads, :except => [:destroy, :index, :update, :remove]

  match '/dash/history/items' => 'dash/history#items'

  match 'formats/list', :controller => 'formats', :action => 'list'
  match 'formats/listwithblank', :controller => 'formats', :action => 'listwithblank'
  planner_resources :formats

  match 'edited_bios/exportbiolist.:format', :controller => 'edited_bios',:action => 'exportbiolist'
  match 'edited_bios/selectExportBioList', :controller => 'edited_bios',:action => 'selectExportBioList'
  resources :edited_bios do
    resources :person
  end
  resources :bio_images do
    resources :person
  end

  #
  # For "external" images linked to instance through the polymorphic relationship
  #
  match "external_images(/:cname/:cid)(/:use)",     :controller => 'external_images', :via => :get,     :action => 'index'
  match "external_images(/:cname/:cid)/:use/:id",   :controller => 'external_images', :via => :get,     :action => 'show'
  match "external_images(/:cname/:cid)/:use",       :controller => 'external_images', :via => :post,    :action => 'create'
  match "external_images(/:cname/:cid)(/:use)/:id", :controller => 'external_images', :via => :put,     :action => 'update'
  match "external_images/:id",                      :controller => 'external_images', :via => :delete,  :action => 'destroy'

  #
  #
  #
  match "gallery_images/:type/:gallery",    :controller => 'gallery_images', :via => :get,     :action => 'index'
  match "gallery_images/:id",               :controller => 'gallery_images', :via => :get,     :action => 'show'
  match "gallery_images/:type/:gallery",    :controller => 'gallery_images', :via => :post,    :action => 'create'
  match "gallery_images/:id",               :controller => 'gallery_images', :via => :delete,  :action => 'destroy'

  #
  resources :available_dates

  # map.connect 'tags/list.:format', :controller => 'tags', :action => 'list'
  match 'tags/list.:format', :controller => 'tags', :action => 'list'
  # match 'tags/:id', :controller => 'tags', :action => 'show', :via => 'get'
  # match 'tags/:id', :controller => 'tags', :action => 'add', :via => 'post'  
  # match 'tags/:id/remove', :controller => 'tags', :action => 'remove', :via => 'get'  
  resources :tags do
    member do
      get 'remove'
      post 'add'
      get 'show'
      get 'index'
      get 'edit'
    end
  end
  
  resources :tag_contexts

  match 'invitation_categories/list', :controller => 'invitation_categories', :action => 'list'
  resources :invitation_categories

  resources :available_dates do
    resources :person
  end  

  #
  #
  # TODO - check these routes
  match 'survey_respondents/tags_admin', :controller => 'survey_respondents/tags_admin', :action => 'index'
  match 'survey_respondents/tags_admin/update', :controller => 'survey_respondents/tags_admin', :action => 'update', :via => :post
  match 'survey_respondents/tags_admin/fix', :controller => 'survey_respondents/tags_admin', :action => 'fix'
  
  match 'survey_respondents/tags/cloud', :controller => 'survey_respondents/tags', :action => 'cloud'
  match 'survey_respondents/tags/alltags', :controller => 'survey_respondents/tags', :action => 'alltags'
  match 'survey_respondents/tags/update', :controller => 'survey_respondents/update', :action => 'list', :method => 'post'

  #
  # Utilities to review surveys
  #  
  match 'survey_respondents/reviews/surveys/:person_id',  :controller => 'survey_respondents/reviews', :action => 'surveys', :method => 'get'
  match 'survey_respondents/reviews/:id(/:survey_id)',    :controller => 'survey_respondents/reviews', :action => 'show', :method => 'get'

  #
  #
  #
  resources :survey_respondents do
    resources :tags, :controller => 'survey_respondents/tags', :except => [:destroy, :new, :create, :edit, :remove] do
      member do
        get 'cloud'
        get 'alltags'
        get 'list'
        post 'update'
      end
    end
  end
  # These also take the context as a parameter...
  match 'survey_respondents/tags/alltags', :controller => 'survey_respondents/tags', :action => 'alltags'
  match 'survey_respondents/tags/cloud', :controller => 'survey_respondents/tags', :action => 'cloud'

  resources :equipment_needs do
    resources :programme_items
  end

  resources :excluded_items_survey_maps do 
    resources :programme_items, :mapped_survey_questions
  end

  resources :registrationDetails
  
  resources :postal_addresses do
    # resources :people
  end
  resources :email_addresses do
    resources :people
  end
  resources :phone_numbers do
    resources :people
  end

  match 'pending_import_people/import_file', :controller => 'pending_import_people', :action => 'import_file'
  match 'pending_import_people/get_possible_matches', :controller => 'pending_import_people', :action => 'get_possible_matches'
  match 'pending_import_people/merge_all_pending', :controller => 'pending_import_people', :action => 'merge_all_pending'
  match 'pending_import_people/merge_pending', :controller => 'pending_import_people', :action => 'merge_pending'
  match 'pending_import_people/create_from_pending', :controller => 'pending_import_people', :action => 'create_from_pending'
  resources :pending_import_people

  match 'program_planner/assignments', :controller => 'program_planner', :action => 'assignments', :method => 'get'
  match 'program_planner/addItem', :controller => 'program_planner', :action => 'addItem', :method => 'post'
  match 'program_planner/removeItem', :controller => 'program_planner', :action => 'removeItem', :method => 'get'
  match 'program_planner/getConflicts', :controller => 'program_planner', :action => 'getConflicts', :method => 'get'

  match 'publisher/publish', :controller => 'publisher', :action => 'publish', :method => 'post'
  match 'publisher/review', :controller => 'publisher', :action => 'review', :method => 'get'
  match 'publisher/publishPending', :controller => 'publisher', :action => 'publishPending', :method => 'get'
  match 'publisher', :controller => 'publisher', :action => 'index', :method => 'get'

  match 'rooms/list.:format', :controller => 'rooms', :action => 'list' #, :defaults => { :format => 'json' }
  match 'rooms/simple_list', :controller => 'rooms', :action => 'simple_list', :defaults => { :format => 'json' }
  resources :rooms, :defaults => { :format => 'json' } do
    post :update_row_order, on: :collection
  end

  match 'setup_types/list.:format', :controller => 'setup_types', :action => 'list'
  match 'setup_types/picklist', :controller => 'setup_types', :action => 'picklist'
  resources :setup_types

  match 'room_setups/list', :controller => 'room_setups', :action => 'list'
  resources :room_setups

  match 'venue/list', :controller => 'venue', :action => 'list', :defaults => { :format => 'json' }
  resources :venue, :defaults => { :format => 'json' } do
    post :update_row_order, on: :collection
  end

  resources :datasources
  resources :mail_configs
  resources :cloudinary_config
  resources :mail_templates
  resources :site_configs
  resources :equipment_types


  #
  #
  #
  match 'communications/mail_history',          :controller => 'communications/mail_history', :action => 'index',         :method => 'get'
  match 'communications/mail_history/list',     :controller => 'communications/mail_history', :action => 'list',          :method => 'post'
  match 'communications/mailing/addPeople',     :controller => 'communications/mailing',      :action => 'addPeople',     :method => 'put'
  match 'communications/mailing/removePeople',  :controller => 'communications/mailing',      :action => 'removePeople',  :method => 'put'
  match 'communications/mailing/previewEmail',  :controller => 'communications/mailing',      :action => 'previewEmail',  :method => 'get'
  match 'communications/mailing/listWithBlank', :controller => 'communications/mailing',      :action => 'listWithBlank', :method => 'get'
  namespace :communications do
    resources :mailing
    resources :mail_templates
  end

  resources :person_mailing_assignments, :controller => 'admin/person_mailing_assignments'
  match :mailing_configs, :controller => 'admin/mailing_configs'

  # TODO
  match 'surveys/list', :controller => 'surveys', :action => 'list'
  resources :surveys do
    resources :response, :controller => 'surveys/response'
    resources :survey_groups, :controller => 'surveys/survey_groups' do
      resources :survey_questions, :controller => 'surveys/survey_groups/survey_questions'
    end
  end
  
  match 'survey_query/list.:format', :controller => 'survey_query', :action => 'list'  
  match 'survey_query/questions', :controller => 'survey_query', :action => 'questions', :defaults => { :format => 'json' }
  match 'survey_query/copy/:id', :controller => 'survey_query', :action => 'copy'  
  resources :survey_query

  match 'survey_reports/extract_all/:survey_id', :controller => 'survey_reports', :action => 'extract_all', :defaults => { :format => 'xlsx' }
  match 'survey_reports/:action', :controller => 'survey_reports'

  match 'planner_reports/:action', :controller => 'planner_reports'
  resources :planner_reports

  match 'program/publicationDates.:format', :controller => 'program', :action => 'publicationDates', :method => 'get'
  
  match 'program.:format', :controller => 'program', :action => 'index', :method => 'get'
  match 'program/rooms.:format', :controller => 'program', :action => 'rooms', :method => 'get'
  match 'program/participants.:format', :controller => 'program', :action => 'participants', :method => 'get'
  match 'program/updates.:format', :controller => 'program', :action => 'updates', :method => 'get'
  match 'program/confirmed_participants.:format', :controller => 'program', :action => 'confirmed_participants', :method => 'get'
  resources :program

  match '/form/:page(/:preview)', :controller => 'surveys/response', :action => 'renderalias'

  match 'tasks/update_exclusions', :controller => 'tasks/update_exclusions', :action => 'index'

  # Tools for exporting
  match "tools/people_exporter/export", :controller => 'tools/people_exporter', :action => 'export', :defaults => { :format => 'xlsx' }
  match "tools/item_exporter/export", :controller => 'tools/item_exporter', :action => 'export', :defaults => { :format => 'xlsx' }
  match "tools/cloud_tools/sign", :controller => 'tools/cloud_tools', :action => 'sign' #, :defaults => { :format => 'json' }

  planner_resources 'category_names',         :defaults => { :format => 'json' }
  planner_resources 'theme_names',         :defaults => { :format => 'json' }
  planner_resources 'published_programme_items', :defaults => { :format => 'json' }
end
