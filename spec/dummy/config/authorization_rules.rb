authorization do
  
  role :Viewer do
    has_permission_on :addresses, :to => [:read]
    has_permission_on :availabilities, :to => [:read]
    has_permission_on :available_dates, :to => [:read]
    has_permission_on :edited_bios, :to => [:read]
    has_permission_on :email_addresses, :to => [:read]
    has_permission_on :equipment_types, :to => :read
    has_permission_on :equipment_needs, :to => :read
    has_permission_on :excluded_items, :to => [:read]
    has_permission_on :excluded_items_survey_maps, :to => [:read]
    has_permission_on :formats, :to => [:read]
    has_permission_on :invitation_categories, :to => [:read]
    has_permission_on :item_planner, :to => [:read]
    has_permission_on :pending_import_people, :to => [:read]
    has_permission_on :people, :to => [:read]
    has_permission_on :phone_numbers, :to => [:read]
    has_permission_on :planner_reports, :to => [:read]
    has_permission_on :postal_addresses, :to => [:read]
    has_permission_on :programme_items, :to => [:read]
    has_permission_on :program_planner, :to => [:read]
    has_permission_on :publisher, :to => :review
    has_permission_on :registration_details, :to => [:read]
    has_permission_on :roles, :to => [:read]
    has_permission_on :rooms, :to => [:read]
    has_permission_on :room_setups, :to => :read
    has_permission_on :survey_query, :to => :read
    has_permission_on :survey_respondents, :to => :read
    has_permission_on :survey_respondents_reviews, :to => [:read]
    has_permission_on :survey_reports, :to => [:read]
    has_permission_on :tag_contexts, :to => [:read]
    has_permission_on :tags, :to => [:read]
    has_permission_on :venue, :to => [:read]
    
    has_permission_on :pages_home_dash, :to => :read
    has_permission_on :pages_venues_dash, :to => :read
    has_permission_on :pages_participants_dash, :to => :read
    has_permission_on :pages_items_dash, :to => :read
    has_permission_on :pages_schedule_dash, :to => :read
    has_permission_on :pages_surveys_dash, :to => :read
    has_permission_on :pages_reports_dash, :to => :read
    has_permission_on :pages_publications_dash, :to => :read
    has_permission_on :communications_mailing, :to => :read
    has_permission_on :bio_images, :to => :read
    
    has_permission_on :dash_history, :to => :read
    
  end

  role :TagAdmin do
    includes :Viewer
    has_permission_on :survey_respondents_tags_admin, :to => :manage
  end
  
  role :Itemeditor do
    includes :Viewer
    has_permission_on :programme_items, :to => :manage
    has_permission_on :tags, :to => :manage
    has_permission_on :equipment_types, :to => :manage
    has_permission_on :equipment_needs, :to => :manage
    has_permission_on :panels_item_mgmt, :to => :manage
  end
  
  role :Planner do
    includes :Itemeditor
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
    has_permission_on :program_planner, :to => :manage
    has_permission_on :registration_details, :to => :manage
    has_permission_on :roles, :to => [:read]
    has_permission_on :rooms, :to => :manage
    has_permission_on :survey_respondents, :to => :manage
    has_permission_on :survey_respondents_reviews, :to => :manage
    has_permission_on :tag_contexts, :to => :manage
    has_permission_on :venue, :to => :manage
    has_permission_on :survey_reports, :to => :manage
    has_permission_on :planner_reports, :to => :manage
    has_permission_on :availabilities, :to => :manage
    has_permission_on :available_dates, :to => :manage
    has_permission_on :excluded_items_survey_maps, :to => [:manage]
    has_permission_on :programme_items, :to => :schedule
    has_permission_on :publisher, :to => :schedule
    has_permission_on :emailreports, :to => :read
    has_permission_on :survey_query, :to => :manage
    has_permission_on :survey_reports, :to => :report
    has_permission_on :pages_communications_dash, :to => :read
    has_permission_on :communications_mail_history, :to => :read
    has_permission_on :communications_mail_templates, :to => :read
    has_permission_on :surveys, :to => :read
    has_permission_on :communications_mailing, :to => :manage
  end
  
  role :SuperPlanner do
     includes :Planner
     has_permission_on :addresses, :to => :supermanage
     has_permission_on :edited_bios, :to => :supermanage
     has_permission_on :email_addresses, :to => :supermanage
     has_permission_on :formats, :to => :supermanage
     has_permission_on :invitation_categories, :to => :supermanage
     has_permission_on :item_planner, :to => :supermanage
     has_permission_on :pending_import_people, :to => :supermanage
     has_permission_on :people, :to => :supermanage
     has_permission_on :phone_numbers, :to => :supermanage
     has_permission_on :postal_addresses, :to => :supermanage
     has_permission_on :programme_items, :to => :supermanage
     has_permission_on :program_planner, :to => :supermanage
     has_permission_on :registration_details, :to => :supermanage
     has_permission_on :rooms, :to => :supermanage
     has_permission_on :survey_respondents, :to => :supermanage
     has_permission_on :survey_respondents_reviews, :to => :supermanage
     has_permission_on :tag_contexts, :to => :supermanage
     has_permission_on :tags, :to => :supermanage
     has_permission_on :venue, :to => :supermanage
     has_permission_on :survey_reports, :to => :supermanage
     has_permission_on :planner_reports, :to => :supermanage
     has_permission_on :availabilities, :to => :supermanage
     has_permission_on :available_dates, :to => :supermanage
     has_permission_on :excluded_items_survey_maps, :to => [:supermanage]
     has_permission_on :equipment_types, :to => :supermanage
     has_permission_on :equipment_needs, :to => :supermanage
     has_permission_on :surveys, :to => :supermanage
     has_permission_on :survey_respondents_tags_admin, :to => :manage
  end

  role :Admin do
    has_omnipotence
  end
  
end

privileges do
    privilege :review, :includes => [:review]
    privilege :report, :includes => [:library_talks,:missing_bio,:moderators,:art_night,:music_night,:program_types,:free_text,:tags_by_context,:available_during,:panels_with_panelists,:panelists_with_panels,
        :people_without_panels, :admin_tags_by_context,:panels_date_form,:panelists_with_metadata,:interviewable,:panels_by_room,:panels_by_timeslot,:failed,:sent, 
        :surveyNames, :surveyQueryNames, :show, :questions, :runReport, :delSurveyQuery, :table_tents, :people_by_tag, :badge_labels, :room_signs]
    privilege :read, :includes => [:report, :index, :show, :list, :listwithblank, :comphrensive,:acceptancestatuslist,:acceptancestatuslistwithblank,:ReportInviteStatus,
        :doReportInviteStatus,:invitestatuslist,:invitestatuslistwithblank,:getConflicts,:getRoomControl, :updateSelect, :getList, :list, :assignments, :listWithBlank, :items]
    privilege :manage, :includes => [:create, :read, :update, :delete, :communicate, :add, :remove, :updateParticipants, :copy,
                                      :SetInvitePendingToInvited, :doSetInvitePendingToInvited, :addItem, :removeItem,:program_book_report, :addPeople]
    privilege :create, :includes => [:new,:import,:doimport]
    privilege :update, :includes => [:edit,:states,:copySurvey,:updateExcludedItemsFromSurveys,:updateExcludedTimesFromSurveys]
    privilege :delete, :includes => [:destroy, :removeItem]
    privilege :communicate, :includes => [:doexportemailxml,:exportbiolist, :selectExportBioList, :schedule_report, :BackOfBadge, :selectBadgeLabel, :selectScheduleReport,:RoomSign,:selectRoomSign, :tableTents,:selectTableTents]
    privilege :schedule, :includes => [:manage, :publish]
    privilege :supermanage, :includes => [:manage, :drop, :exportemailxml]
end
