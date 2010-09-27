class SurveyRespondentsController < SurveyApplicationController
  before_filter :check_for_single_access_token, :only => [:show, :edit, :update]

  def show
    @survey_respondent = @current_survey_respondent
  end

end
