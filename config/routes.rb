PlannerRc1::Application.routes.draw do

  namespace :pages do
    resources :home_dash
    match "participants_dash/:cellname" => "participants_dash#index"
    # resources :participants_dash # TODO - map back to the default participant dash or need a default can not find
    match "items_dash/:cellname" => "items_dash#index"
    match "schedule_dash/:cellname" => "schedule_dash#index"
    # resources :items_dash
    resources :logistics_dash
    resources :admin_dash
    resources :publications_dash
    resources :reports_dash
    resources :mailings_dash
    resources :surveys_dash
    resources :venues_dash
  end
  
  # Default routes 
  # root :to => 'user_sessions#new'
  root :to => 'pages/home_dash#index'
  
  # The top level menu - TODO - change in redesign
  resources :menus

  #
  # The new(s) were removed so as to prevent anonymous people creating new accounts
  #
  resources :users, :except => [:new, :index]
  resource :user, :as => 'account', :except => [:new, :index]  # convenience route
  resource :user_session
  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout

  # For user and user management
  match 'usersadmin/list' => 'users/admin#list'
  resources :usersadmin, :controller => 'users/admin'
  match 'roles/list' => 'roles#list'

# TODO - test
  match 'participants/ReportInviteStatus', :controller => 'people', :action => 'ReportInviteStatus'
  match 'participants/doReportInviteStatus', :controller => 'people', :action => 'doReportInviteStatus'
  match 'participants/exportemailxml', :controller => 'people', :action => 'exportemailxml'
  match 'participants/doexportemailxml.:format', :controller => 'people', :action => 'doexportemailxml', :method => 'post'
  match 'participants/doSetInvitePendingToInvited', :controller => 'people', :action => 'doSetInvitePendingToInvited', :method => 'post'
  match 'participants/SetInvitePendingToInvited', :controller => 'people', :action => 'SetInvitePendingToInvited'
  match 'participants/invitestatuslist', :controller => 'people', :action => 'invitestatuslist'
  match 'participants/acceptancestatuslist', :controller => 'people', :action => 'acceptancestatuslist'
  match 'participants/updateConflictsFromSurvey',:controller => 'people', :action => 'updateConflictsFromSurvey', :method => 'post'
  match 'participants/clearConflictsFromSurvey',:controller => 'people', :action => 'clearConflictsFromSurvey'
  match 'participants/doClearConflictsFromSurvey',:controller => 'people', :action => 'doClearConflictsFromSurvey', :method => 'post'
  match 'participants/getList',:controller => 'people', :action => 'getList', :method => 'post'
  match 'participants/count', :controller => 'people', :action => 'count', :method => 'get'
# 
  # resources :people, :as => "participants" do
  match 'participants/acceptancestatuslistwithblank', :controller => 'people', :action => 'acceptancestatuslistwithblank'
  match 'participants/invitestatuslistwithblank', :controller => 'people', :action => 'invitestatuslistwithblank'
  # resources :participants, :controller => "people" do
  resources :people, :path => "participants" do
    resources :addresses, :postalAddresses, :emailAddresses, :phoneNumbers, :availabilities, :programme_items
    resources :registrationDetails do
      get 'show'
    end
    resources :edited_bios, :available_dates
    collection do
      get 'list'
      post 'list'
    end
    # member do # TODO - check the member methods that we need to make sure are in place
      # get 'show'
    # end
  end

  match 'formats/list', :controller => 'formats', :action => 'list'
  match 'formats/listwithblank', :controller => 'formats', :action => 'listwithblank'
  resources :formats

  match 'edited_bios/exportbiolist.:format', :controller => 'edited_bios',:action => 'exportbiolist'
  match 'edited_bios/selectExportBioList', :controller => 'edited_bios',:action => 'selectExportBioList'
  resources :edited_bios do
    resources :person
  end#, :has_one => :person
  
  resources :available_dates

  # map.resources :people, :as => "participants", 
    # :has_many => [:addresses, :postalAddresses, :emailAddresses, :phoneNumbers, :availabilities, :programme_items],
    # :has_one => [:registrationDetail, :edited_bio, :available_date],
    # :collection => {:list => [:post, :get] },
    # :member => {:show => :get}
  # map.connect 'participants/list', :controller => 'people', :action => 'list'

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
   #, :member => {:remove => :get, :add => :post, :index => :get, :edit => :get} #,
      # :except => [:destroy, :new, :create]
# 
  resources :tag_contexts

  match 'invitation_categories/list', :controller => 'invitation_categories', :action => 'list'
  resources :invitation_categories

  resources :available_dates do
    resources :person
  end  
#    , :has_one => :person
# 

  # #
  # #
  # #
  # map.resources :survey_respondent_sessions # just for the new session...
# 
  #
  #
  # TODO - check these routes
  match 'survey_respondents/tags_admin', :controller => 'survey_respondents/tags_admin', :action => 'index'
  match 'survey_respondents/tags_admin/update', :controller => 'survey_respondents/tags_admin', :action => 'update', :via => :post
  match 'survey_respondents/tags_admin/fix', :controller => 'survey_respondents/tags_admin', :action => 'fix'
  match 'survey_respondents/tags/cloud', :controller => 'survey_respondents/tags', :action => 'cloud'
  match 'survey_respondents/tags/alltags', :controller => 'survey_respondents/tags', :action => 'alltags'
  # match 'survey_respondents/tags/list', :controller => 'survey_respondents/list', :action => 'list'
  match 'survey_respondents/tags/update', :controller => 'survey_respondents/update', :action => 'list', :method => 'post'
  # resources :survey_respondents 
  
  #
  match 'survey_respondents/reviews/list', :controller => 'survey_respondents/reviews', :action => 'list'
  namespace :survey_respondents do
    resources :reviews do
      member do
        get 'list'
        get 'states'
        post 'copySurvey'
      end
    end
  end
#     

  # map.resources :survey_respondents do |respondent|
    # respondent.resource :tags, :member => {:cloud => :get, :alltags => :get, :list => :get, :update => :post}, 
      # :controller => 'survey_respondents/tags',
      # :except => [:destroy, :new, :create, :edit, :remove]
  # end
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

  match 'programme_items/assign_reference_numbers', :controller => 'programme_items', :action => 'assign_reference_numbers'
  match 'programme_items/do_assign_reference_numbers', :controller => 'programme_items', :action => 'do_assign_reference_numbers',:method => 'post'
  match 'programme_items/drop', :controller => 'programme_items', :action => 'drop', :method => 'get'
  match 'programme_items/list', :controller => 'programme_items', :action => 'list'
  match 'programme_items/getList',:controller => 'programme_items', :action => 'getList', :method => 'post'

  resources :programme_items do
    resources :excluded_items_survey_maps,:mapped_survey_questions,:equipment_needs
    member do
      put 'updateParticipants'
    end
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

  match 'pending_import_people/import', :controller => 'pending_import_people', :action => 'import'
  match 'pending_import_people/doimport', :controller => 'pending_import_people', :action => 'doimport', :method => 'post'   
  resources :pending_import_people

  resources :item_planner, :only => :index # TODO - check

  match 'program_planner/assignments', :controller => 'program_planner', :action => 'assignments', :method => 'get'
  match 'program_planner/addItem', :controller => 'program_planner', :action => 'addItem', :method => 'post'
  match 'program_planner/removeItem', :controller => 'program_planner', :action => 'removeItem', :method => 'get'
  match 'program_planner/getConflicts', :controller => 'program_planner', :action => 'getConflicts', :method => 'get'
  # match 'program_planner/list', :controller => 'program_planner', :action => 'list', :method => 'post'
  # resources :program_planner, :member => {:index => :get, :edit => :get}


  match 'publisher/publish', :controller => 'publisher', :action => 'publish', :method => 'get'
  match 'publisher/review', :controller => 'publisher', :action => 'review', :method => 'get'
  resources :publisher, :member => {:index => :get},
      :except => [:destroy, :new, :create, :edit, :show, :update, :list]


  match 'rooms/list.:format', :controller => 'rooms', :action => 'list'
  match 'rooms/listwithblank', :controller => 'rooms', :action => 'listwithblank'
  match 'rooms/picklist', :controller => 'rooms', :action => 'picklist'
  resources :rooms

  match 'setup_types/list.:format', :controller => 'setup_types', :action => 'list'
  match 'setup_types/picklist', :controller => 'setup_types', :action => 'picklist'
  resources :setup_types

  match 'room_setups/list', :controller => 'room_setups', :action => 'list'
  resources :room_setups

  match 'venue/list', :controller => 'venue', :action => 'list'
  resources :venue

  resources :datasources
  resources :mail_configs
  resources :mail_templates

  match 'emailreports/failed', :controller => 'emailreports', :action => 'failed', :method => 'get'  
  match 'emailreports/sent', :controller => 'emailreports', :action => 'sent', :method => 'get'  
  match 'emailreports', :controller => 'emailreports', :action => 'index', :method => 'get'  
  resources :emailreports

  resources :equipment_types

  resources :mail_history, :controller => 'mail/mail_history', :only => [:index]
  match 'mail_history/count', :controller => 'mail/mail_history', :action => 'count', :method => 'get'

  match 'mailings/list', :controller => 'admin/mailings', :action => 'list', :method => 'get'
  match 'mailings/del', :controller => 'admin/mailings', :action => 'del', :method => 'delete'
  match 'mailings/previewEmail', :controller => 'admin/mailings', :action => 'previewEmail', :method => 'get'
  resources :mailings, :controller => 'admin/mailings'

  namespace :reports do
    resources :mail_reports, :only => [:index]
  end

  resources :person_mailing_assignments, :controller => 'admin/person_mailing_assignments'
  match :mailing_configs, :controller => 'admin/mailing_configs'

  resources :surveys do
    resources :response, :controller => 'surveys/response'
    resources :survey_groups, :controller => 'surveys/survey_groups' do
      resources :survey_questions, :controller => 'surveys/survey_groups/survey_questions'
    end
  end
  resources :survey_query

  match 'survey_reports/:action', :controller => 'survey_reports' #,  :member => {:list => :get, :del => :delete }
  match 'survey_reports/surveyQueryNames/:id', :controller => 'survey_reports', :action => 'delSurveyQuery', :method => :delete
  resources :survey_reports

  match 'planner_reports/:action', :controller => 'planner_reports'
  resources :planner_reports

  match 'program/publicationDates.:format', :controller => 'program', :action => 'publicationDates', :method => 'get'
  match 'program/updateSelect', :controller => 'program', :action => 'updateSelect', :method => 'get'
  
  match 'program/rooms.:format', :controller => 'program', :action => 'rooms', :method => 'get'
  match 'program/streams.:format', :controller => 'program', :action => 'streams', :method => 'get'
  match 'program/participants.:format', :controller => 'program', :action => 'participants', :method => 'get'
  match 'program/participants_and_bios.:format', :controller => 'program', :action => 'participants_and_bios', :method => 'get'
  match 'program/feed.:format', :controller => 'program', :action => 'feed', :method => 'get'
  match 'program/updates.:format', :controller => 'program', :action => 'updates', :method => 'get'
  match 'program/grid.:format', :controller => 'program', :action => 'grid', :method => 'get'
  match 'program.:format', :controller => 'program', :action => 'index', :method => 'get'
  resources :program

  match '/form/:page', :controller => 'surveys/response', :action => 'renderalias'
  # #map.resources :surveys, :has_many => :survey_groups
  # map.resources :surveys do |survey|
    # survey.resources :survey_groups, :controller => 'surveys/survey_groups' do |group|
      # group.resources :survey_questions, :controller => 'surveys/survey_groups/survey_questions'
    # end
    # survey.resources :response, :controller => 'surveys/response'
  # end
#   
# 
#   
# 
  # map.resources :survey_copy_statuses
  # map.resources :monitor, :only => :index # we only need the one method/route for this
  # map.resources :mapped_survey_questions
  # map.resource :user_session
  # map.root :controller => "user_sessions", :action => "new"
  # map.login "login", :controller => "user_sessions", :action => "new"
  # map.logout "logout", :controller => "user_sessions", :action => "destroy"
  # map.resources :excluded_times
# 
#   

end
