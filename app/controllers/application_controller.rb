#
#
#
class ApplicationController < ActionController::Base
  
  before_filter :set_locale
 
  def set_locale
    I18n.locale = (params[:locale] && params[:locale].size > 0)? params[:locale] : I18n.default_locale
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
