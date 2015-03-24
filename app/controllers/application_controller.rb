#
#
#
class ApplicationController < ActionController::Base
  include Planner::ControllerExtensions
  
  before_filter :first_filter, :set_locale, :load_configs, :set_mailer_host, :last_filter
  around_filter :application_time_zone # make sure that we use the timezone as specified in the database
  
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  
  helper_method :current_user_session, :current_respondent
  
  def current_user
    user = nil
    if support_user_signed_in?
      user = current_support_user
    else
      user = @current_user ||= warden.authenticate(scope: :user)
    end
    user
  end
  
  after_filter :store_prev_location
    
  private

    def store_prev_location
      # store last url - this is needed for post-login redirect to whatever the user last visited.
      return unless request.get? 
      if (!request.path.include?("/sign_in") &&
          !request.path.include?("/sign_up") &&
          !request.path.include?("/password/new") &&
          !request.path.include?("/password/edit") &&
          !request.path.include?("/confirmation") &&
          !request.path.include?("/sign_out") &&
          !request.path.include?("/identify") &&
          !request.xhr?) # don't store ajax calls
        session[:previous_url] = request.fullpath 
        store_location
      end
    end  
  
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
      user_signed_in? or support_user_signed_in?
    end
    
    def current_respondent
      return @respondent if defined?(@respondent)
      nil
    end
    
    def current_user_session
      user_session if user_signed_in?
      support_user_session if support_user_signed_in?
    end

    def require_user
      unless current_user || current_support_user
        # Rack::MiniProfiler.authorize_request        
        store_location
        flash[:notice] = "You must be logged in to access this page"
        redirect_to new_user_session_url
        return false
      end
    end

# TODO - FIX
    def require_no_user
      if current_user || current_support_user
        store_location
        #flash[:notice] = "You must be logged out to access this page"
        redirect_to account_url
        return false
      end
    end

end
