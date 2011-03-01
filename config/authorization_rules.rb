authorization do
  
  role :viewer do
    has_permission_on :people, :to => [:read]
    has_permission_on :programme_items, :to => [:read]
    has_permission_on :rooms, :to => [:read]
    has_permission_on :venue, :to => [:read]
    has_permission_on :formats, :to => [:read]
    has_permission_on :invitation_categories, :to => [:read]
    has_permission_on :tags, :to => [:read]
    has_permission_on :survey_respondents_reviews, :to => [:read]
    has_permission_on :edited_bios, :to => [:read]
  end
  
  role :Planner do
    has_permission_on :people, :to => :manage
    has_permission_on :programme_items, :to => :manage
    has_permission_on :rooms, :to => :manage
    has_permission_on :venue, :to => :manage
    has_permission_on :survey_respondents, :to => :manage
    has_permission_on :formats, :to => :manage
    has_permission_on :invitation_categories, :to => :manage
    has_permission_on :tags, :to => :manage
    has_permission_on :pending_import_people, :to => :manage
    has_permission_on :survey_respondents_reviews, :to => :manage
    has_permission_on :edited_bios, :to => :manage
  end
  
  role :Admin do
    has_omnipotence
  end
  
end

privileges do
    privilege :manage, :includes => [:create, :read, :update, :delete,:communicate]
    privilege :read, :includes => [:index, :show, :list, :listwithblank, :comphrensive,:acceptancestatuslist,:acceptancestatuslistwithblank,:ReportInviteStatus,:doReportInviteStatus,:invitestatuslist,:invitestatuslistwithblank]
    privilege :create, :includes => [:new,:import,:doimport]
    privilege :update, :includes => [:edit,:states,:copySurvey]
    privilege :delete, :includes => :destroy
    privilege :communicate, :includes => [:exportemailxml,:doexportemailxml]
end