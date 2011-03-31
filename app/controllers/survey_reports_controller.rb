#
#
#
class SurveyReportsController < PlannerController
  before_filter :check_for_single_access_token, :only => [:show, :index]
  
  def show
  end
  
  def index
  end
 
  def library_talks
    @library_talkers = Person.all :select => 'people.*, smerf_forms_surveyrespondents.id', :joins => 'join survey_respondents on people.id = survey_respondents.person_id join smerf_forms_surveyrespondents on survey_respondents.id = smerf_forms_surveyrespondents.surveyrespondent_id join smerf_responses on smerf_forms_surveyrespondents.id = smerf_responses.smerf_forms_surveyrespondent_id', :conditions => "question_code = 'g93q7' and response = '1'", :group => 'people.id', :having => 'smerf_forms_surveyrespondents.id = max(smerf_forms_surveyrespondents.id)', :order => 'last_name'
  end
 
  def missing_bio
    @missing_bio = Person.all :joins => 'join survey_respondents on people.id = survey_respondents.person_id left join edited_bios on survey_respondents.person_id = edited_bios.person_id', :conditions => 'edited_bios.id is NULL and survey_respondents.attending = 1 and survey_respondents.submitted_survey = 1', :order => 'last_name'
  end
  
  def moderators
    @moderators = Person.all :select => 'people.*, smerf_forms_surveyrespondents.id', :joins => 'join survey_respondents on people.id = survey_respondents.person_id join smerf_forms_surveyrespondents on survey_respondents.id = smerf_forms_surveyrespondents.surveyrespondent_id join smerf_responses on smerf_forms_surveyrespondents.id = smerf_responses.smerf_forms_surveyrespondent_id', :conditions => "question_code = 'g9q4' and response = '1'", :group => 'people.id', :having => 'smerf_forms_surveyrespondents.id = max(smerf_forms_surveyrespondents.id)', :order => 'last_name'
  end
 
  def music_night
    @music_night = Person.all :select => 'people.*, smerf_responses.response, smerf_forms_surveyrespondents.id', :joins => 'join survey_respondents on people.id = survey_respondents.person_id join smerf_forms_surveyrespondents on survey_respondents.id = smerf_forms_surveyrespondents.surveyrespondent_id join smerf_responses on smerf_forms_surveyrespondents.id = smerf_responses.smerf_forms_surveyrespondent_id', :conditions => "question_code = 'g91q1'", :group => 'people.id', :having => 'smerf_forms_surveyrespondents.id = max(smerf_forms_surveyrespondents.id)', :order => 'last_name'
  end

  def art_night
    @art_night = Person.all :select => 'people.*, smerf_responses.response, smerf_forms_surveyrespondents.id', :joins => 'join survey_respondents on people.id = survey_respondents.person_id join smerf_forms_surveyrespondents on survey_respondents.id = smerf_forms_surveyrespondents.surveyrespondent_id join smerf_responses on smerf_forms_surveyrespondents.id = smerf_responses.smerf_forms_surveyrespondent_id', :conditions => "question_code = 'g92q1'", :group => 'people.id', :having => 'smerf_forms_surveyrespondents.id = max(smerf_forms_surveyrespondents.id)', :order => 'last_name'
  end
end
