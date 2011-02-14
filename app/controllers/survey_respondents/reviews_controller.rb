class SurveyRespondents::ReviewsController < PlannerController

  def index
  end

  def show
    # Get the respondent
    respondent = SurveyRespondent.find(params[:id])
    
    # Get the survey
    @smerf_user_id = respondent.id # check
#    @respondent_form = SmerfFormsSurveyrespondent.find_user_smerf_form(respondent.id, 1)
    @form = SmerfForm.find_by_id(1)
    smerf_forms_surveyrespondent = SmerfFormsSurveyrespondent.find_user_smerf_form(respondent.id, 1)
    @responses = smerf_forms_surveyrespondent.responses

    render :layout => 'content'
  end

  def list
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]

    clause = createWhereClause(params[:filters])
    clause = addClause(clause, 'submitted_survey = ?', true)

    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB      
    @count = SurveyRespondent.count :conditions => clause
    @nbr_pages = (@count / rows.to_i).floor + 1
    @nbr_pages += 1 if @count % rows.to_i > 0
    
    off = (@page.to_i - 1) * rows.to_i
    @respondents = SurveyRespondent.find :all, :conditions => clause,
      :offset => off, :limit => rows, :order => idx + " " + order
   
    # We return the list of people as an XML structure which the 'table' can us
    respond_to do |format|
      format.xml
    end
  end

end
