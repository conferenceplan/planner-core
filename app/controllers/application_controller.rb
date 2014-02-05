#
#
#
class ApplicationController < ActionController::Base
  
  before_filter :set_locale, :load_cloudinary_config
  around_filter :application_time_zone # make sure that we use the timezone as specified in the database
 
  def set_locale
    I18n.locale = (params[:locale] && params[:locale].size > 0)? params[:locale] : I18n.default_locale
  end
  
  def application_time_zone(&block)
    cfg = SiteConfig.find :first # for now we only have one convention... change when we have many (TODO)
    if (cfg) # TODO - temp, to be replaced in other code
      SITE_CONFIG[:conference][:name] = cfg.name
      SITE_CONFIG[:conference][:number_of_days] = cfg.number_of_days
      SITE_CONFIG[:conference][:start_date] = cfg.start_date
      SITE_CONFIG[:conference][:time_zone] = cfg.time_zone
    end
    Time.use_zone(SITE_CONFIG[:conference][:time_zone], &block)
  end
  
  def load_cloudinary_config
    cfg = CloudinaryConfig.find :first # for now we only have one convention... change when we have many (TODO)
    Cloudinary.config do |config|
      config.cloud_name           = cfg ? cfg.cloud_name : ''
      config.api_key              = cfg ? cfg.api_key : ''
      config.api_secret           = cfg ? cfg.api_secret : ''
      config.enhance_image_tag    = cfg ? cfg.enhance_image_tag : false
      config.static_image_support = cfg ? cfg.static_image_support : false
     config.cdn_subdomain = true
    end
  end
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery
  
  helper_method :current_user_session, :current_user
  
  private
    def check_for_single_access_token # TODO - change name???
      if params[:key] && !params[:key].empty?
        @respondent       = SurveyRespondent.find_by_single_access_token(params[:key]) 
        @current_respondent_session = SurveyRespondentSession.create!(@respondent) 
      end
    end 
    
    #
    #
    #
    def user_logged_in?
      if current_user
        return true
      else
        return false
      end
    end
    
    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.user
    end
  
    def require_user
      unless current_user
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
      session[:return_to] = request.url
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
end
