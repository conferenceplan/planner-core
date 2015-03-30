module Planner
  module ControllerExtensions

    def first_filter
      # do nowt
    end
  
    def last_filter
      # do nowt
    end
  
    def set_mailer_host
      ActionMailer::Base.default_url_options[:host] = request.host_with_port
    end
     
    def set_locale
      I18n.locale = (params[:locale] && params[:locale].size > 0)? params[:locale] : I18n.default_locale
    end
    
    def application_time_zone(&block)
      cfg = SiteConfig.find :first # for now we only have one convention... change when we have many
      zone = cfg ? cfg.time_zone : Time.zone
      Time.use_zone(zone, &block)
    end
    
    def load_configs
      cfg = CloudinaryConfig.find :first # for now we only have one convention... change when we have many
      Cloudinary.config do |config|
        config.cloud_name           = cfg ? cfg.cloud_name : ''
        config.api_key              = cfg ? cfg.api_key : ''
        config.api_secret           = cfg ? cfg.api_secret : ''
        config.enhance_image_tag    = cfg ? cfg.enhance_image_tag : false
        config.static_image_support = cfg ? cfg.static_image_support : false
       config.cdn_subdomain = true
      end
      
      mail_cfg = MailConfig.find :first
      if mail_cfg
        Devise.setup do |config|
          config.mailer_sender = mail_cfg.from
        end
      end
    end

    def store_location
      session[:return_to] = request.protocol + request.host_with_port + request.fullpath
    end
    
    def store_page page
      session[:page] = page
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
    
    def survey_redirect_back(default, token)
      if session[:return_to]
        redirect_to((session[:return_to] + '/?key=' + token) || default)
      else
        redirect_to(default + '/?key=' + token)
      end      
    end
    
    def get_stored_page
      session[:page]
    end

  end
end
