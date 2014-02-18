#
#
#
class SurveyRespondentsController < ApplicationController
  before_filter :check_for_single_access_token, :only => [:show, :edit, :update, :confirm]

  layout "dynasurvey"

  def new
    @survey_respondent = SurveyRespondent.new
    @page_title = "Questionnaire Start"
    page = get_stored_page
    @survey = Survey.find_by_alias(page)
    config = MailConfig.first
    if config.info
      @ourEmail = config.info
    else
      @ourEmail = config.from
    end  
  end

  #
  # TODO - if no survey has been specified then we want to go to a participant home page....  
  #
  def create
    key       = params[:key]
    last_name = params[:last_name]

    # find a respondent with the key and last name
    @survey_respondent = findRespondent(key, last_name) if (key && key != '')

    # We need to get the survey that is to be filled in, if we do not have page then we can get if back
    page = get_stored_page
    @survey = Survey.find_by_alias(page)
    
    if @survey_respondent
      
      @survey_respondent.attending = params[:cancel] # Indicate whether or not the person said that they are attending
      # Redirect the person to the survey
      if @survey_respondent.save
        if params[:cancel]
          begin
            MailService.sendEmail(@survey_respondent.person, MailUse[:DeclinedSurvey], @survey, (@survey_respondent ? @survey_respondent.survey_respondent_detail : nil))
          rescue => ex
            logger.error "No email template. We were not able to send the email to " + @survey_respondent.person
          end
          redirect_to  '/nosurvey.html' # TODO - to be changed
        else # Otherwise we continue to the form
          # TODO - change the '/' to the participant page (for past surveys and managing availabilities etc.)
          survey_redirect_back '/', @survey_respondent.single_access_token
        end
      else
        # there was a problem so return to the new page
        flash[:error] = "Unable to save the information. Please try again."
        render :action => :new
      end
    else
      # there was a problem so return to the 'login' page
      @survey_respondent = SurveyRespondent.new
      flash[:error] = "Unable to find a potential participant that matches the inputs."
      render :action => :new
    end
  end

  # For now the update does the same as the create
  def update
    create
  end

  # show and index does not really make that much sense.... just redirect to the 'new' action
  def show
    redirect_to '/survey_respondents/new'
  end
  
  def index
    redirect_to '/survey_respondents/new'
  end

private

  def findRespondent(key, last_name)
    respondent = nil
    # use the join to lookup by the name of the person
    candidate = SurveyRespondent.find :first, :joins => :person, 
                                      :conditions => ["survey_respondents.key = ? AND people.last_name = ?", key, last_name]
    # since the join is a read only result set we need to get the actual survey_respondent to store the acceptance status in
    respondent = SurveyRespondent.find(candidate.id) if candidate != nil
    respondent
  end
  
end
