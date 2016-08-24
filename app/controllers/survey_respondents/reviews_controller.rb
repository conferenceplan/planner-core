class SurveyRespondents::ReviewsController < PlannerController
  include SurveyHtmlFormatter

  #
  #
  #
  def show
    @respondent = nil
    survey_id = params[:survey_id].to_i
    
    if survey_id != 0
      @survey = Survey.find(survey_id)
    else
      @survey = Survey.find_by_alias('partsurvey') # a default cause the conventions used to use part survey....
    end
  
    # we need the survey and the survey respondent
    if params[:id].to_i != 0
      person_id = params[:id].to_i
      @respondent = SurveyRespondent.find :first,
        :conditions => ["survey_respondents.person_id = ? and survey_respondent_details.id is not null and survey_responses.survey_id = ?", person_id, survey_id],
        :include => { :survey_respondent_detail => {:survey_responses => {}, :survey_respondent => {}} }
    end
    
    render json: { 'survey' => survey_to_html(@survey,@respondent.survey_respondent_detail, false) }, :content_type => 'application/json'
  end

  #
  # Return the surveys for specific person
  #  
  def surveys
    person_id = params[:person_id]
    
    surveys = SurveyService.findSurveysForPerson person_id
    
    render json: surveys.to_json, :content_type => 'application/json'
  end
  
end
