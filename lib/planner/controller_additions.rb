module Planner
  module ControllerAdditions
    
    def self.included(base)
      base.helper_method :allowed?, :top_menu, :basePlainUri, :baseUri, :baseUri_no_lang, :baseUri_with_lang,
                         :extra_navigation, :extra_navigation_left, :extra_navigation_right, :extra_participant_tabs, :extra_item_tabs, :settings_menu,
                         :request_path, :current_identity, :current_attendee, :omniauth_state_params, :get_base_image_url, :get_logo,
                         :strip_html_tags, :site_url, :site_url_no_lang, :only_free_tickets_available?,
                         :public_start_date, :public_end_date, :public_days, :conference_name,
                         :start_date, :end_date, :conference_days, :event_is_over?, :google_map_key, :event_name, :event_duration, :event_happening_now?,
                         :human_time, :person_img_url, :current_user, :org_info_email,
                         :current_event, :current_event?
    end

    def current_event
      nil
    end

    def current_event?
      nil
    end

    def org_info_email
      mail_configs = MailConfig.where("info != ?", "info@grenadine.co")
      if mail_configs && mail_configs.any?
        mail_configs.first.info
      else
        ""
      end
    end

    def current_user
      user = nil
      if support_user_signed_in?
        user = current_support_user
      else
        user = @current_user ||= warden.authenticate(scope: :user)
      end
      user
    end
    
    def human_time mins
      [[60, I18n.t(:minutes)], [24, I18n.t(:hours)], [1000, I18n.t(:days)]].map{ |count, name|
        if mins && mins > 0
          mins, n = mins.divmod(count)
          "#{n.to_i} #{(n == 1 ? name.to_s.singularize : name)}" if n > 0
        end
      }.compact.reverse.join(' ')
    end

    def google_map_key
      key = ""
      key = ENV["GOOGLE_MAP_KEY"] if ENV["GOOGLE_MAP_KEY"].present?
      key
    end
    
    def start_date
      SiteConfig.first.start_date if SiteConfig.first
    end
    
    def end_date
      (SiteConfig.first.start_date + (SiteConfig.first.number_of_days - 1).day).end_of_day if SiteConfig.first
    end
    
    def conference_days
      SiteConfig.first.number_of_days if SiteConfig.first
    end
    
    alias_method :event_duration, :conference_days

    def conference_name
      SiteConfig.first ? SiteConfig.first.name : ''
    end

    alias_method :event_name, :conference_name
    
    def public_start_date
      SiteConfig.first.public_start_date if SiteConfig.first
    end

    def public_end_date
      (SiteConfig.first.public_start_date + (SiteConfig.first.public_number_of_days - 1).day) if SiteConfig.first
    end

    def public_days
      SiteConfig.first.public_number_of_days if SiteConfig.first
    end

    def event_happening_now?
      Date.today >= start_date.to_date && Date.today <= ( start_date.to_date + (event_duration.days - 1.day)).to_date
    end
    
    def event_is_over?
      ((start_date + (event_duration-1).days).to_date - Date.today).to_i < 0
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
      logo = ConferenceLogo.unscoped.find_by(conference_id: conference.id) if conference
      
      if logo && logo.image
        logo.scale = scale
        img = logo.image
        image_url(img)
      else
        nil
      end
    end

    def person_img_url person, scale: 1, version: :detail, default_img: nil
      url = ENV['G_DEFAULT_PERSON_IMAGE_URL'] #start with default grenadine person image url. This will get replaced by the others if the correct conditions are met
      if person && person.bio_image
        img = person.bio_image
        img.scale = scale
        image = img.bio_picture.send(version)
        
        if image && image.url
          url = image_url(image)
        end
        # if the person has an image, use that image
      elsif default_img.present? || DefaultBioImage.first.present?
        img = default_img || DefaultBioImage.first
        img.scale = scale
        image = img.image.send(version)
        
        if image && image.url
          url = image_url(image)
        end
        # if there is no person image but there is a default image, use that one
      end
      
      url
    end

    def image_url(im)
      if im && im.url
        base = get_base_image_url
        url_part = base + im.url.partition(/upload/)[2]
      else
        nil
      end
    end

    def get_base_image_url
      eval(ENV[:base_image_url.to_s])
    end

    def site_url path_extras: nil, lang: true, private_token: true
      ''
    end

    def site_url_no_lang path_extras: nil, private_token: true
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
  
    def extra_navigation_left
      ''
    end
  
    def extra_navigation_right
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
                  { :title => 'prog-items',      :target => '/pages/items_dash/manage', :display => allowed?(:items) },
                  { :title => 'scheduling-conflicts-tab-title',   :target => '/pages/schedule_dash/manage', :display => allowed?(:schedule)  }
                  # conflicts ?
                ]
              } if allowed? :items
      menu << { :title => 'surveys',          :target => '/pages/surveys_dash/manage', :icon => "fa fa-comment",  :target_base => '/pages/surveys_dash',
                :sub_menu => [
                  { :title => 'manage-surveys', :target => '/pages/surveys_dash/manage', :display => allowed?(:manage_surveys) },
                  { :title => 'survey-queries', :target => '/pages/surveys_dash/report', :display => allowed?(:survey_reports) },
                  { :title => 'survey-reports', :target => '/pages/surveys_dash/reporting', :display => allowed?(:survey_reports) }
                ]
              } if allowed? :surveys
      menu << { :title => 'messages',   :target => '/pages//communications_dash/templates', :icon => "fa fa-envelope",  :target_base => '/pages/communications_dash',
                :sub_menu => [
                  { :title => 'manage-mailings', :target => '/pages/communications_dash/manage', :display => allowed?(:manage_mailings) },
                  { :title => 'email-templates', :target => '/pages/communications_dash/templates', :display => allowed?(:mailing_templates) }
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
