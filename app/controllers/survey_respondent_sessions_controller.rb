class SurveyRespondentSessionsController < ApplicationController

  before_filter :require_no_survey_respondent, :only => [:new, :create]
  # before_filter :require_survey_respondent, :only => :destroy

  def new
    # @respondent_session = SurveyRespondentSession.new
  end
  
  # def create
    # logger.debug "**********************"
    # logger.debug params
    # logger.debug params[:respondent_session]
    # @respondent_session = SurveyRespondentSession.new(params[:respondent_session]) # Check params
    # if @respondent_session.save
      # flash[:notice] = "Login successful!"
      # redirect_back_or_default '/' # TODO - change to a different root for survey respondents
    # else
      # flash[:error] = "Login incorrect"
      # render :action => :new
    # end
  # end
#   
  # def destroy
    # current_respondent_session.destroy
    # flash[:notice] = "Logout successful!"
    # redirect_back_or_default new_survey_respondent_session_url
  # end

end
