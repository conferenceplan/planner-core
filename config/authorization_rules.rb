authorization do
  
  role :Viewer do
    has_permission_on :addresses, :to => [:read]
    has_permission_on :edited_bios, :to => [:read]
    has_permission_on :email_addresses, :to => [:read]
    has_permission_on :formats, :to => [:read]
    has_permission_on :invitation_categories, :to => [:read]
    has_permission_on :pending_import_people, :to => [:read]
    has_permission_on :people, :to => [:read]
    has_permission_on :phone_numbers, :to => [:read]
    has_permission_on :postal_addresses, :to => [:read]
    has_permission_on :programme_items, :to => [:read]
    has_permission_on :registration_details, :to => [:read]
    has_permission_on :roles, :to => [:read]
    has_permission_on :rooms, :to => [:read]
    has_permission_on :survey_respondents, :to => :read
    has_permission_on :survey_respondents_reviews, :to => [:read]
    has_permission_on :tag_contexts, :to => [:read]
    has_permission_on :tags, :to => [:read]
    has_permission_on :venue, :to => [:read]
  end

  role :TagAdmin do
    includes :Viewer
    has_permission_on :survey_respondents_tags_admin, :to => :manage
  end
  
  role :Planner do
    includes :Viewer
    has_permission_on :addresses, :to => :manage
    has_permission_on :edited_bios, :to => :manage
    has_permission_on :email_addresses, :to => :manage
    has_permission_on :formats, :to => :manage
    has_permission_on :invitation_categories, :to => :manage
    has_permission_on :pending_import_people, :to => :manage
    has_permission_on :people, :to => :manage
    has_permission_on :phone_numbers, :to => :manage
    has_permission_on :postal_addresses, :to => :manage
    has_permission_on :programme_items, :to => :manage
#    has_permission_on :registration_details, :to => :manage
    has_permission_on :roles, :to => [:read]
    has_permission_on :rooms, :to => :manage
    has_permission_on :survey_respondents, :to => :manage
    has_permission_on :survey_respondents_reviews, :to => :manage
    has_permission_on :tag_contexts, :to => :manage
    has_permission_on :tags, :to => :manage
    has_permission_on :venue, :to => :manage
  end
  
  role :Admin do
    has_omnipotence
  end
  
end

privileges do
    privilege :read, :includes => [:index, :show, :list, :listwithblank, :comphrensive,:acceptancestatuslist,:acceptancestatuslistwithblank,:ReportInviteStatus,:doReportInviteStatus,:invitestatuslist,:invitestatuslistwithblank]
    privilege :manage, :includes => [:create, :read, :update, :delete, :communicate, :add, :remove]
    privilege :create, :includes => [:new,:import,:doimport]
    privilege :update, :includes => [:edit,:states,:copySurvey]
    privilege :delete, :includes => :destroy
    privilege :communicate, :includes => [:exportemailxml,:doexportemailxml,:exportbiolist]
end
