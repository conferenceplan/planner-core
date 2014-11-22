module Planner
  module ControllerAdditions
    
    module ClassMethods
    end
    
    def self.included(base)
      base.extend ClassMethods
      base.helper_method :allowed?, :top_menu
    end
    
    def allowed?(item) # take target as the name
      return true
    end
    
    def top_menu_additions
      return {}
    end

    def top_menu
      #  return the hash for the top menu
      return {
        "venues"           => ({ :target => '/pages/venues_dash/manage',           :icon => "glyphicon-th-list",   :target_base => '/pages/venues_dash'} if allowed? :venues),
        "participants"     => ({ :target => '/pages/participants_dash/manage',     :icon => "glyphicon-user",      :target_base => '/pages/participants_dash'} if allowed? :participants),
        "program-items"    => ({ :target => '/pages/items_dash/manage',            :icon => "glyphicon-tasks",     :target_base => '/pages/items_dash'} if allowed? :items),
        "schedule"         => ({ :target => '/pages/schedule_dash/manage',         :icon => "glyphicon-calendar",  :target_base => '/pages/schedule_dash'} if allowed? :schedule),
        "surveys"          => ({ :target => '/pages/surveys_dash/report',          :icon => "glyphicon-pencil",    :target_base => '/pages/surveys_dash'} if allowed? :surveys),
        "communications"   => ({ :target => '/pages//communications_dash/manage',  :icon => "glyphicon-envelope",  :target_base => '/pages/communications_dash'} if allowed? :communications),
        "reports"          => ({ :target => '/pages/reports_dash/manage',          :icon => "glyphicon-stats",     :target_base => '/pages/reports_dash'} if allowed? :reports),
        "publications"     => ({ :target => '/pages/publications_dash/print',      :icon => "glyphicon-print",     :target_base => '/pages/publications_dash'} if allowed? :publications),
        "admin"            => ({ :target => '/pages/admin_dash/users',             :icon => "glyphicon-wrench",    :target_base => '/pages/admin_dash'} if allowed? :admin)
      }.keep_if{|k,v| v}.merge!(top_menu_additions)
    end
      
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include Planner::ControllerAdditions
  end
  
  Cell::Rails.class_eval do
    include Planner::ControllerAdditions
  end
end
