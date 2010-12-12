#
#
#
class SurveyRespondentsController < SurveyApplicationController
  before_filter :check_for_single_access_token, :only => [:show, :edit, :update, :confirm]
  
  def new
    @survey_respondent = SurveyRespondent.new
    @page_title = "Renovation Survey Start"
  end
  
  def create
    @survey_respondent = nil
    key = params[:survey_respondent][:key]
    fillSurvey = true
    
    # Check to see if the respondent has said that they will not be attending
    if (params[:cancel]) # Then we do not go to the survey
      # TODO save the fact that they will not be attending and then forward to a thank you page
      fillSurvey = false
    end
    
    # TODO - there should be a link between the survey_respondent and the participant, determine the direction (both ways)
    
    # find a respondent with the key, if not found then create a new one
    if (key)
      # TODO - put in code to also validate the last name that they are using matches the one that we have in the DB
      @survey_respondent = SurveyRespondent.find_by_key(key)
      if (@survey_respondent)
        @survey_respondent.attending = fillSurvey
      end
    end
    
    # Create a new survey respondent based on the first and last name...
    if (! @survey_respondent ) # create a new survey respondent and survey (to be linked to participant manually)
      @survey_respondent = SurveyRespondent.new(params[:survey_respondent])
      # Create a key for this new survey respondent
      @survey_respondent.key = '%05d' % rand(1e5) # ensure that we do not save the key to the database
    end
    
    if @survey_respondent.save and fillSurvey
      # Redirect the person to the survey
      redirect_to '/smerf_forms/partsurvey?key=' + @survey_respondent.single_access_token
    else
      # there was a problem so return to the new page
      render :action => :new
    end
    
  end

  # For now the update does the same as the create
  def update
    create
  end

  def confirm
    @survey_respondent = @current_survey_respondent
    
    SurveyMailer.deliver_thankyou_email(@survey_respondent)
    
    render :layout => 'content'
  end
  
  # TODO - once they have completed the survey we should send them an email to confirm that the survey
  # has been completed. Also with a link to the survey (with single access token) that they can use to edit/update
  # the survey.
  #
  # NOTE: do we want to put in a date after which the survey can not be edited?
  
  # show and index does not really make that much sense.... just redirect to the 'new' action
  def show
    redirect_to '/survey_respondents/new'
  end
  
  def index
    redirect_to '/survey_respondents/new'
  end
  
end
