authorization do
  
  role :Viewer do
    has_permission_on :addresses, :to => [:read]
    has_permission_on :edited_bios, :to => [:read]
    has_permission_on :email_addresses, :to => [:read]
    has_permission_on :formats, :to => [:read]
    has_permission_on :invitation_categories, :to => [:read]
    has_permission_on :item_planner, :to => [:read]
    has_permission_on :pending_import_people, :to => [:read]
    has_permission_on :people, :to => [:read]
    has_permission_on :phone_numbers, :to => [:read]
    has_permission_on :postal_addresses, :to => [:read]
    has_permission_on :programme_items, :to => [:read]
    has_permission_on :program_planner, :to => [:read]
    has_permission_on :registration_details, :to => [:read]
    has_permission_on :roles, :to => [:read]
    has_permission_on :rooms, :to => [:read]
    has_permission_on :survey_respondents, :to => :read
    has_permission_on :survey_respondents_reviews, :to => [:read]
    has_permission_on :tag_contexts, :to => [:read]
    has_permission_on :tags, :to => [:read]
    has_permission_on :venue, :to => [:read]
    has_permission_on :survey_reports, :to => [:read]
    has_permission_on :planner_reports, :to => [:read]
    has_permission_on :availabilities, :to => [:read]
    has_permission_on :excluded_items, :to => [:read]
    has_permission_on :excluded_items_survey_maps, :to => [:read]
    has_permission_on :available_dates, :to => [:read]
  end

  role :TagAdmin do
    includes :Viewer
    has_permission_on :survey_respondents_tags_admin, :to => :manage
  end
  
  role :Itemeditor do
    includes :Viewer
    has_permission_on :programme_items, :to => :manage
    has_permission_on :tags, :to => :manage
  end
  
  role :Planner do
    includes :Viewer
    has_permission_on :addresses, :to => :manage
    has_permission_on :edited_bios, :to => :manage
    has_permission_on :email_addresses, :to => :manage
    has_permission_on :formats, :to => :manage
    has_permission_on :invitation_categories, :to => :manage
    has_permission_on :item_planner, :to => :manage
    has_permission_on :pending_import_people, :to => :manage
    has_permission_on :people, :to => :manage
    has_permission_on :phone_numbers, :to => :manage
    has_permission_on :postal_addresses, :to => :manage
    has_permission_on :programme_items, :to => :manage
    has_permission_on :program_planner, :to => :manage
    has_permission_on :registration_details, :to => :manage
    has_permission_on :roles, :to => [:read]
    has_permission_on :rooms, :to => :manage
    has_permission_on :survey_respondents, :to => :manage
    has_permission_on :survey_respondents_reviews, :to => :manage
    has_permission_on :tag_contexts, :to => :manage
    has_permission_on :tags, :to => :manage
    has_permission_on :venue, :to => :manage
    has_permission_on :survey_reports, :to => :manage
    has_permission_on :planner_reports, :to => :manage
    has_permission_on :availabilities, :to => :manage
    has_permission_on :available_dates, :to => :manage
  end
  
  role :Admin do
    has_omnipotence
  end
  
end

privileges do
    privilege :report, :includes => [:library_talks,:missing_bio,:moderators,:art_night,:music_night,:program_types,:free_text,:tags_by_context,:available_during,:panels_with_panelists,:panelists_with_panels,:admin_tags_by_context,:panels_date_form]
    privilege :read, :includes => [:report, :index, :show, :list, :listwithblank, :comphrensive,:acceptancestatuslist,:acceptancestatuslistwithblank,:ReportInviteStatus,
        :doReportInviteStatus,:invitestatuslist,:invitestatuslistwithblank,:getConflicts,:getRoomControl]
    privilege :manage, :includes => [:create, :read, :update, :delete, :communicate, :add, :remove, :updateParticipants,
                                      :SetInvitePendingToInvited, :doSetInvitePendingToInvited, :addItem, :removeItem,:updateExcludedItemsFromSurveys]
    privilege :create, :includes => [:new,:import,:doimport]
    privilege :update, :includes => [:edit,:states,:copySurvey]
    privilege :delete, :includes => [:destroy, :removeItem]
    privilege :communicate, :includes => [:exportemailxml,:doexportemailxml,:exportbiolist, :selectExportBioList]
end
