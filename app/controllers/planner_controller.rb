#
#
#
class PlannerController < ApplicationController
  
  # before_filter :authenticate_user!
  before_filter :check_authenticated

  #ensure_authorization_performed :unless => :devise_controller?
  #ensure_authorization_performed :except => [:index, :search], :if => :auditing_security?, :unless => :devise_controller?
  
  # before_filter :require_user # All controllers that inherit from this will require an authenticated user
  filter_access_to :all # All controllers that inherit from this will be controlled by the access rules

  rescue_from ActiveRecord::StaleObjectError do |exception|
    respond_to do |format|
      format.html {
        correct_stale_record_version
        stale_record_recovery_action
      }
      format.xml  { head :conflict }
      format.json { head :conflict }
    end
  end      

  def permission_denied
    respond_to do |format|
      format.json {
        render status: :bad_request, text: 'You do not have permission to perform the requested action'
      }
      format.html {
        render '/errors/permission_error'
      }
    end
  end

protected

  def set_return_to(path)
    session[:user_return_to] = path
  end

  def stale_record_recovery_action
    flash.now[:error] = "Another user has made a change to that record "+
         "since you accessed the edit form."
    render :edit, :status => :conflict, :layout => 'content'
  end

  def check_authenticated 
    set_return_to request.fullpath
    redirect_to '/users/sign_in' unless user_signed_in? or support_user_signed_in? 
  end  
end
