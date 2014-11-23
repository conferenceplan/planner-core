#
#
#
class ApplicationController < ActionController::Base
  helper PlannerHelper
  
  before_filter :first_filter, :set_locale, :load_configs, :set_mailer_host
  around_filter :application_time_zone # make sure that we use the timezone as specified in the database
  
  def first_filter
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
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  
  helper_method :current_user_session, :current_user, :current_respondent
  
  private
    def check_for_single_access_token # TODO - change name???
      if params[:key] && !params[:key].empty?
        @respondent                 = SurveyRespondent.where({:single_access_token => params[:key]}).first
      end
    end 
    
    #
    #
    #
    def respondent_logged_in?
      return current_respondent != nil
    end
    
    #
    #
    #
    def user_logged_in?
      user_signed_in?
    end
    
    def current_respondent
      return @respondent if defined?(@respondent)
      nil
    end
    
    def current_user_session
      user_session
    end

    def require_user
      unless current_user
        # Rack::MiniProfiler.authorize_request        
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end

# TODO - FIX
    def require_no_user
      if current_user
        store_location
        #flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end
    
    #
    #
    #
    def store_location
      session[:return_to] = request.protocol + request.host_with_port + baseUri + request.fullpath
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
