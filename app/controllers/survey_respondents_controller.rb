class SurveyRespondentsController < SurveyApplicationController
  before_filter :check_for_single_access_token, :only => [:show, :edit, :update]

  def new
    @survey_respondent = SurveyRespondent.new
  end
  
  def create
    key = params[:survey_respondent][:key]
    @survey_respondent = nil
    
    # find a respondent with the key, if not found then create a new one
    if (key)
      @survey_respondent = SurveyRespondent.find_by_key(key)
    end
    
    # else let them know that we did not find the key and ask them if they want to continue without it

    if (! @survey_respondent )
      @survey_respondent = SurveyRespondent.new(params[:survey_respondent])
    end

    # TODO - redirect the person to the survey
    if @survey_respondent.save
      # URL plus parameter
      redirect_to '/smerf_forms/partsurvey?key=' + @survey_respondent.single_access_token
    else
      render :action => :new
    end
  end

  def show
    @survey_respondent = @current_survey_respondent

    render :layout => 'content'
  end

  def index
    @survey_respondent = @current_survey_respondent

    render :layout => 'content'
  end

end
