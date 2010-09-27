class SurveyRespondentSessionsController < SurveyApplicationController

  before_filter :require_no_survey_respondent, :only => [:new, :create]

  def new
    @user_session = UserSession.new
    
    render :layout => 'login'
  end

end
