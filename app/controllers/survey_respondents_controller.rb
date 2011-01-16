#
#
#
class SurveyRespondentsController < SurveyApplicationController
  before_filter :check_for_single_access_token, :only => [:show, :edit, :update, :confirm]
  
  def new
    @survey_respondent = SurveyRespondent.new
    @page_title = "Renovation Questionnaire Start"
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
      @survey_respondent = SurveyRespondent.find_by_key(key)
      if (@survey_respondent)
        if @survey_respondent.last_name.eql?(last_name)
          @survey_respondent.attending = fillSurvey
        else
          @survey_respondent = nil
        end
      end
    end
    
    if @survey_respondent
      # Redirect the person to the survey
      if @survey_respondent.save
        # Get the related person and update their acceptance status...
        person = @survey_respondent.person
        if person
          person.acceptance_status = (fillSurvey) ? AcceptanceStatus.find_by_name("Accepted") : AcceptanceStatus.find_by_name("Declined")
          person.save
        end

        if (fillSurvey)
          redirect_to '/smerf_forms/partsurvey?key=' + @survey_respondent.single_access_token
        else
          SurveyMailer.deliver_decline_email(@survey_respondent)

          redirect_to  '/nosurvey.html'
        end
      else
        # there was a problem so return to the new page
        flash[:error] = "Unable to save the information. Please try again."
        render :action => :new
      end
    else
      # there was a problem so return to the new page
      @survey_respondent = SurveyRespondent.new
      flash[:error] = "Unable to find a potential participant that matches the inputs."
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
