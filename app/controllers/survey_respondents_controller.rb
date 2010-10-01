#
#
#
class SurveyRespondentsController < SurveyApplicationController
  before_filter :check_for_single_access_token, :only => [:show, :edit, :update]

  def new
    @survey_respondent = SurveyRespondent.new
  end
  
  def create
    @survey_respondent = nil
    key = params[:survey_respondent][:key]
    
    # Check to see if the respondent has said that they will not be attending
    if (params[:cancel]) # Then we do not go to the survey
      logger.debug "CANCEL THE FORM"
      # TODO save the fact that they will not be attending and then forward to a thank you page
    else
      # TODO - there should be a link between the survey_respondent and the participant, determine the direction (both ways)
    
      # find a respondent with the key, if not found then create a new one
      if (key)
        @survey_respondent = SurveyRespondent.find_by_key(key)
      end
    
      # TODO: else let them know that we did not find the key and ask them if they want to continue without it

      if (! @survey_respondent ) # create a new survey respondent and survey (to be linked to participant manually)
        @survey_respondent = SurveyRespondent.new(params[:survey_respondent])
      end

      if @survey_respondent.save
        # Redirect the person to the survey
        redirect_to '/smerf_forms/partsurvey?key=' + @survey_respondent.single_access_token
      else
        # there was a problem so return to the new page
        render :action => :new
      end
    end
    
  end
  
  # TODO - once they have completed the survey we should send them an email to confirm that the survey
  # has been completed. Also with a link to the survey (with single access token) that they can use to edit/update
  # the survey.
  #
  # NOTE: do we want to put in a date after which the survey can not be edited?

  # TODO - show and index does not really make that much sense....
  def show
    @survey_respondent = @current_survey_respondent

    render :layout => 'content'
  end

  def index
    @survey_respondent = @current_survey_respondent

    render :layout => 'content'
  end

end
