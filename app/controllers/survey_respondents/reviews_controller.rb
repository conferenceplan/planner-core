class SurveyRespondents::ReviewsController < PlannerController

  def index
  end

  def show
    @respondent = nil
    if !@survey
      @survey = Survey.find_by_alias('partsurvey') #find(params[:survey_id])
    end
  
    # we need the survey and the survey respondent
    @respondent = SurveyRespondent.find(
        params[:id],
        :include => { :survey_respondent_detail => {:survey_responses => {}, :survey_respondent => {}} }
      ) if params[:id] != 0
    
    render :layout => 'content'
  end

  def list
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]

    clause = createWhereClause(params[:filters])
    # clause = addClause(clause, 'submitted_survey = ?', true)

    clause = addClause(clause,'people.acceptance_status_id = ? ',8)
    args = { :conditions => clause }
    args.merge!( :joins => 'LEFT JOIN people ON people.id = survey_respondents.person_id' )

    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB      
    @count = SurveyRespondent.count args
    @nbr_pages = (@count / rows.to_i).floor + 1
    @nbr_pages += 1 if @count % rows.to_i > 0
    
    off = (@page.to_i - 1) * rows.to_i
    args.merge!(:offset => off, :limit => rows, :order => idx + " " + order)

    @respondents = SurveyRespondent.find :all, args
   
    # We return the list of people as an XML structure which the 'table' can us
    respond_to do |format|
      format.xml
    end
  end
  
  def states
    @copyStatus = SurveyCopyStatus.first :conditions => ["survey_respondent_id = ?", params[:id]]
    @respondentId = params[:id]
    
    render :layout => 'content'
  end
  
end
