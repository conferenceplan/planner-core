#
#
#
class SurveyRespondentsController < ApplicationController
  before_filter :check_for_single_access_token, :only => [:show, :edit, :update, :confirm]

  layout "dynasurvey"

  def new
    @site_config = SiteConfig.first
    @survey_respondent = SurveyRespondent.new
    @page_title = "Questionnaire Start"
    page = get_stored_page
    @survey = Survey.find_by(alias: page)
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
    @site_config = SiteConfig.first
    @survey_respondent = findRespondent(key, last_name) if (key && key != '')

    # We need to get the survey that is to be filled in, if we do not have page then we can get if back
    page = get_stored_page
    @survey = Survey.find_by(alias: page)
    
    if @survey_respondent
      
      @survey_respondent.attending = params[:cancel] # Indicate whether or not the person said that they are attending
      # Redirect the person to the survey
      if @survey_respondent.save
        if params[:cancel]
          @survey = Survey.find_by(alias: "partsurvey") if !@survey
          if (@survey.decline_status && @survey_respondent.person) # TODO hanle case of no surevy selected?????
            @survey_respondent.person.acceptance_status = @survey.decline_status
            @survey_respondent.person.save!
          end
          
          begin
            MailService.sendEmail(@survey_respondent.person, MailUse[:DeclinedSurvey], @survey, (@survey_respondent ? @survey_respondent.survey_respondent_detail : nil))
          rescue => ex
            logger.error "No email template. We were not able to send the email to " + @survey_respondent.person.getFullName
          end

          render 'no_survey'
        else # Otherwise we continue to the form
          # TODO - change the '/' to the participant page (for past surveys and managing availabilities etc.)
          @survey_respondent.single_access_token = (0...25).map { ('a'..'z').to_a[rand(26)] }.join # generate random key for access
          @survey_respondent.save
          survey_redirect_back '/form/partsurvey', @survey_respondent.single_access_token
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
    @site_config = SiteConfig.first
    create
  end

  # show and index does not really make that much sense.... just redirect to the 'new' action
  def show
    @site_config = SiteConfig.first
    redirect_to '/survey_respondents/new'
  end
  
  def index
    @site_config = SiteConfig.first
    redirect_to '/survey_respondents/new'
  end

private

  def findRespondent(key, last_name)
    respondent = nil
    # use the join to lookup by the name of the person
    candidate = SurveyRespondent.includes(:person).references(:person).
                      where(["survey_respondents.key = ? AND people.last_name = ?", key, last_name]).first
    
    # since the join is a read only result set we need to get the actual survey_respondent to store the acceptance status in
    respondent = SurveyRespondent.find(candidate.id) if candidate != nil
    respondent
  end
  
end
