module Planner
  module ControllerAdditions
    
    # module ClassMethods
    # end
    
    def self.included(base)
      base.extend ClassMethods
      base.helper_method :allowed?, :top_menu, :baseUri, :baseUri_no_lang, :extra_navigation, :extra_participant_tabs, :extra_item_tabs
    end
    
    def allowed?(item) # take target as the name
      return true
    end

    def baseUri
      '/' + I18n.locale.to_s
    end
  
    def baseUri_no_lang
      ''
    end
    
    def extra_navigation
      ''
    end
  
    def extra_participant_tabs
      ''
    end
  
    def extra_item_tabs
      ''
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
        "admin"            => ({ :target => '/pages/admin_dash/configs',           :icon => "glyphicon-wrench",    :target_base => '/pages/admin_dash'} if allowed? :admin)
      }.keep_if{|k,v| v}.merge!(top_menu_additions)
    end
      
  end
end
