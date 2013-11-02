class SurveyRespondents::ReviewsController < PlannerController

  def show
    @respondent = nil
    if !@survey
      @survey = Survey.find_by_alias('partsurvey') #find(params[:survey_id])
    end
  
    # we need the survey and the survey respondent
    if params[:id].to_i != 0
      person_id = params[:id].to_i
      @respondent = SurveyRespondent.find :first,
        :conditions => ["person_id = ?", person_id],
        :include => { :survey_respondent_detail => {:survey_responses => {}, :survey_respondent => {}} }
    end
    
    render :layout => 'content'
  end
  
end
