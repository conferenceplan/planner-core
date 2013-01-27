#
#
#
class SurveyRespondentsController < SurveyApplicationController
  before_filter :check_for_single_access_token, :only => [:show, :edit, :update, :confirm]
  
  def new
    @survey_respondent = SurveyRespondent.new
    @page_title = "Questionnaire Start"
    
    config = MailConfig.first
    if config.info
      @ourEmail = config.info
    else
      @ourEmail = config.from
    end  
  end
  
  def create
    @survey_respondent = nil
    key = params[:key]
    last_name = params[:last_name]
    fillSurvey = true
    
    # Check to see if the respondent has said that they will not be attending
    if (params[:cancel]) # Then we do not go to the survey
      # Save the fact that they will not be attending and then forward to a thank you page
      fillSurvey = false
    end
    
    # find a respondent with the key and last name
    if (key)
      # use the join to lookup by the name of the person
      candidate = SurveyRespondent.find :first,
        :joins => :person, 
        :conditions => ["survey_respondents.key = ? AND people.last_name = ?", key, last_name]
      # since the join is a read only result set we need to get the actual survey_respondent to store the acceptance status in
      @survey_respondent = SurveyRespondent.find(candidate.id)
    end
    
    if @survey_respondent
      @survey_respondent.attending = fillSurvey # Indicate whether or not the person said that they are attending
      # Redirect the person to the survey
      if @survey_respondent.save
        # Get the related person and update their acceptance status...
        person = @survey_respondent.person
        if person
          if (fillSurvey )
            if (person.acceptance_status != AcceptanceStatus[:Accepted])
              person.acceptance_status = AcceptanceStatus[:Probable]
            end
          else
            person.acceptance_status = AcceptanceStatus[:Declined]
          end
          person.save
        end

        if (fillSurvey)
          # If there is a survey to fill out in the new mechanism and use that, otherwise use the SMERF mechanism
          # for now look for the alias questionaire
          # TODO - change so that the survey can be db driven rather than by name (partsurvey)
          survey = Survey.find_by_alias('partsurvey')
          if survey
            redirect_to '/form/partsurvey?key=' + @survey_respondent.single_access_token
          else  
            redirect_to '/smerf_forms/partsurvey?key=' + @survey_respondent.single_access_token
          end
        else
          SurveyMailer.deliver_email(@survey_respondent.email, MailUse[:DeclinedSurvey], { 
            :user => @survey_respondent,
           })

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
