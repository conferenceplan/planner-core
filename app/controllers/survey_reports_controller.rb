#
#
#
class SurveyReportsController < PlannerController
  include SurveyReportHelpers
  
  def index
  end
 
  def library_talks
    @library_talkers = search_survey_exact('g93q7', '1')
  end
 
  def missing_bio
    @missing_bio = Person.all :joins => 'join survey_respondents on people.id = survey_respondents.person_id left join edited_bios on survey_respondents.person_id = edited_bios.person_id', :conditions => "edited_bios.id is NULL and survey_respondents.attending = '1' and survey_respondents.submitted_survey = '1' and people.invitestatus_id = 5", :order => 'last_name'
  end
  
  def moderators
    @moderators = search_survey_exact('g9q4', '1')
  end
 
  def music_night
    @music_night = search_survey('g91q1', '%')
  end

  def art_night
    @art_night = search_survey('g92q1', '%')
  end

  def program_types
    @program_types = GetProgramTypes()
    @interested = search_survey_exact('g9q1', params[:type_id])
  end
 
  def free_text
    @free_text_qs = GetFreeTextQuestions()
    if params[:q_id]
      search_string = '%'+params[:search_string]+'%'
      @names = search_survey(params[:q_id], search_string)
    end
  end
  
  def tags_by_context
    @contexts = GetTagContexts()
    if params[:q_id]
      @names = search_survey(params[:q_id], '%')
    end
  end
end
