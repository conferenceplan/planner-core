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
    last_name = params[:survey_respondent][:last_name]
    fillSurvey = true
    
    # Check to see if the respondent has said that they will not be attending
    if (params[:cancel]) # Then we do not go to the survey
      # Save the fact that they will not be attending and then forward to a thank you page
      fillSurvey = false
    end
    
    # find a respondent with the key, if not found then create a new one
    if (key)
      # TODO - put in code to also validate the last name that they are using matches the one that we have in the DB
      @survey_respondent = SurveyRespondent.find_by_key(key)
      if (@survey_respondent)
#        if @survey_respondent.last_name.eql?(last_name)
          @survey_respondent.attending = fillSurvey
#        else
#          @survey_respondent = nil
#        end
      end
    end
    
    # Create a new survey respondent based on the first and last name...
    if (! @survey_respondent ) # create a new survey respondent and survey (to be linked to participant manually)
      @survey_respondent = SurveyRespondent.new(params[:survey_respondent])
      # Create a key for this new survey respondent
      @survey_respondent.key = '%05d' % rand(1e5) # ensure that we do not save the key to the database
    end
    
    # TODO - put in error responses....
    if @survey_respondent
      # TODO: If they said that they are not attending then redirect to a simple thank you
      # Redirect the person to the survey
      if @survey_respondent.save
        if (fillSurvey)
          redirect_to '/smerf_forms/partsurvey?key=' + @survey_respondent.single_access_token
        else
          redirect_to  '/nosurvey.html'
        end
      else
        # there was a problem so return to the new page
        @survey_respondent.errors.add_to_base("Unable to save the information. Please try again.")
        render :action => :new
      end
    else
      # there was a problem so return to the new page
      @survey_respondent = SurveyRespondent.new
      @survey_respondent.errors.add_to_base("Unable to find a potential participant that matches the inputs.")
      render :action => :new
    end
    
  end

  # For now the update does the same as the create
  def update
    create
  end

  # NOTE: do we want to put in a date after which the survey can not be edited?
  
  # show and index does not really make that much sense.... just redirect to the 'new' action
  def show
    redirect_to '/survey_respondents/new'
  end
  
  def index
    redirect_to '/survey_respondents/new'
  end
  
end
