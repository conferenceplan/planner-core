module Planner
  module ControllerAdditions
    
    def self.included(base)
      base.helper_method :allowed?, :top_menu, :basePlainUri, :baseUri, :baseUri_no_lang, :baseUri_with_lang,
                         :extra_navigation, :extra_participant_tabs, :extra_item_tabs, :settings_menu,
                         :request_path, :current_identity, :current_attendee, :omniauth_state_params, :get_base_image_url, :get_logo,
                         :strip_html_tags, :site_url, :site_url_no_long, :only_free_tickets_available?,
                         :public_start_date, :public_end_date, :public_days, :conference_name
    end
    
    def conference_name
      SiteConfig.first ? SiteConfig.first.name : ''
    end
    
    def public_start_date
      SiteConfig.first.public_start_date if SiteConfig.first
    end

    def public_end_date
      (SiteConfig.first.public_start_date + (SiteConfig.first.public_number_of_days - 1).day) if SiteConfig.first
    end

    def public_days
      SiteConfig.first.public_number_of_days if SiteConfig.first
    end
    
    def only_free_tickets_available?
      false
    end
    
    def strip_html_tags(txt)
      html = Nokogiri::HTML(txt.gsub(/\n|\r/,""))
      html.css('br').each{ |e| e.replace "\n" }
      html.css('p').each{ |e| e.replace(e.text + "\n") }
      html.text.strip
    end

    def get_logo(conference = nil,scale = 2)
      nil
    end

    def get_base_image_url
      eval(ENV[:base_image_url.to_s])
    end

    def site_url
      ''
    end

    def site_url_no_long
      ''
    end

    def omniauth_state_params
      ''
    end

    def current_identity
      nil
    end
    def current_attendee
      nil
    end
    
    def request_path
      basepath = request.fullpath 
      if basepath.include? baseUri
        basepath = basepath.slice(baseUri.length(), basepath.length())
      elsif basepath.include? baseUri_no_lang
        basepath = basepath.slice(baseUri_no_lang.length(), basepath.length())
      end
      basepath
    end
    
    def allowed?(item) # take target as the name
      return true
    end

    def basePlainUri
      '/' + I18n.locale.to_s
    end

    def baseUri
      '/' + I18n.locale.to_s
    end
    
    def baseUri_with_lang(lang)
      '/' + lang.to_s
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

    def top_menu
      #  return the hash for the top menu
      menu = []
      
      menu << { :title => '',               :target => '/', :icon => "glyphicon glyphicon-home" }
      menu << { :title => 'venues',         :target => '/pages/venues_dash/manage', :icon => "fa fa-map-marker" } if allowed? :venues
      menu << { :title => 'participants',   :target => '/pages/participants_dash/manage', :icon => "glyphicon glyphicon-user",      :target_base => '/pages/participants_dash'} if allowed? :participants
      menu << { :title => 'program-items',  :target => '/pages/items_dash/manage', :icon => "fa fa-calendar",     :target_base => '/pages/items_dash',
                :sub_menu => [
                  { :title => 'items',      :target => '/pages/items_dash/manage', :display => allowed?(:items) },
                  { :title => 'schedule',   :target => '/pages/schedule_dash/manage', :display => allowed?(:schedule)  }
                  # conflicts ?
                ]
              } if allowed? :items
      menu << { :title => 'surveys',          :target => '/pages/surveys_dash/manage', :icon => "fa fa-comment",  :target_base => '/pages/surveys_dash',
                :sub_menu => [
                  { :title => 'manage-surveys', :target => '/pages/surveys_dash/manage', :display => allowed?(:manage_surveys) },
                  { :title => 'survey-reports', :target => '/pages/surveys_dash/report', :display => allowed?(:survey_reports) }
                ]
              } if allowed? :surveys
      menu << { :title => 'communications',   :target => '/pages//communications_dash/templates', :icon => "fa fa-envelope",  :target_base => '/pages/communications_dash',
                :sub_menu => [
                  { :title => 'manage-mailings', :target => '/pages/communications_dash/manage', :display => allowed?(:manage_mailings) },
                  { :title => 'mail-templates', :target => '/pages/communications_dash/templates', :display => allowed?(:mailing_templates) }
                ]
              } if allowed? :communications
      menu << { :title => 'reports',        :target => '/pages/reports_dash/manage', :icon => "fa fa-bar-chart",     :target_base => '/pages/reports_dash',
                :sub_menu => [
                  {:title => 'reports', :target => '/pages/reports_dash/manage', :display => allowed?(:reports) }
              ]} if allowed? :reports
      menu << { :title => 'menu-publications',   :target => '/pages/publications_dash/online', :icon => "fa fa-globe",     :target_base => '/pages/publications_dash',
                :sub_menu => [
                  {:title => 'publish', :target => '/pages/publications_dash/online', :display => allowed?(:publish) },
                  {:title => 'print', :target => '/pages/publications_dash/print', :display => allowed?(:print) }
                ]} if allowed? :publications

      menu
    end
    
    # get a menu item by name
    def get_menu_index(menu, name)
      menu.find_index{|item| item[:title] == name }
    end
    
    # insert a new item at the given position
    def insert_menu_item(menu, item, idx)
      menu.insert(idx, item)
    end
    
    def settings_menu
      menu = []
      
      if current_user
        menu << { :title => 'my-profile', :target =>  baseUri + '/users/edit' } if current_user
        menu << { :title => 'event-setup', :target => baseUri + '/pages/admin_dash/configs' } if allowed? :event_setup
        menu << { :title => 'system-settings', :target => basePlainUri + '/pages/admin_dash/system_configs'} if allowed? :system_settings
      end
      
      menu
    end
      
  end
end
