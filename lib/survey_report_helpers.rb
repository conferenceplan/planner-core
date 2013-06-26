module SurveyReportHelpers

  def search_newsurvey_by_answer(answer)
    accepted = AcceptanceStatus.find_by_name("Accepted")        
    invited = InviteStatus.find_by_name("Invited")
    return Person.all :select => 'people.*', :joins => 'join (survey_respondents join (survey_respondent_details join survey_responses on survey_respondent_details.id = survey_responses.survey_respondent_detail_id) on survey_respondents.id = survey_respondent_details.survey_respondent_id) on people.id = survey_respondents.person_id',  :conditions => ["survey_responses.survey_question_id = ? and lower(survey_responses.response) like lower(?) and people.invitestatus_id = ? and people.acceptance_status_id = ? and survey_respondents.attending = '1'", answer.survey_question_id, answer.answer,invited,accepted], :order => 'last_name, first_name'
  end
  
  def search_newsurvey_by_question(question)
    accepted = AcceptanceStatus.find_by_name("Accepted")        
    invited = InviteStatus.find_by_name("Invited")
    return Person.all :select => 'people.*', :joins => 'join (survey_respondents join (survey_respondent_details join survey_responses on survey_respondent_details.id = survey_responses.survey_respondent_detail_id) on survey_respondents.id = survey_respondent_details.survey_respondent_id) on people.id = survey_respondents.person_id',  :conditions => ["survey_responses.survey_question_id = ? and people.invitestatus_id = ? and people.acceptance_status_id = ? and survey_respondents.attending = '1'", question.id,invited,accepted], :order => 'last_name, first_name'
  end
  
  def get_newsurvey_responses_for_question_for_person(question,person_id)
    accepted = AcceptanceStatus.find_by_name("Accepted")        
    invited = InviteStatus.find_by_name("Invited")
    return SurveyResponse.all :select => 'survey_responses.*',:joins => 'join (survey_respondent_details join (survey_respondents join people on people.id = survey_respondents.person_id) on survey_respondent_details.survey_respondent_id = survey_respondents.id) on survey_responses.survey_respondent_detail_id = survey_respondent_details.id', :conditions => ["survey_responses.survey_question_id = ? and people.id = ? and people.invitestatus_id = ? and people.acceptance_status_id = ? and survey_respondents.attending = '1'",question.id,person_id,invited,accepted]; 
  end

end
