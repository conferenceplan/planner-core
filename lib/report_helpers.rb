module ReportHelpers

  def search_survey_exact(question, target)
    return Person.all :select => 'people.*, smerf_responses.response, smerf_forms_surveyrespondents.id', :joins => 'join survey_respondents on people.id = survey_respondents.person_id join smerf_forms_surveyrespondents on survey_respondents.id = smerf_forms_surveyrespondents.surveyrespondent_id join smerf_responses on smerf_forms_surveyrespondents.id = smerf_responses.smerf_forms_surveyrespondent_id', :conditions => ["smerf_responses.question_code = ? and smerf_responses.response = ?", question, target], :group => 'people.id', :having => 'smerf_forms_surveyrespondents.id = max(smerf_forms_surveyrespondents.id)', :order => 'last_name'
  end

  def search_survey(question, target)
    return Person.all :select => 'people.*, smerf_responses.response, smerf_forms_surveyrespondents.id', :joins => 'join survey_respondents on people.id = survey_respondents.person_id join smerf_forms_surveyrespondents on survey_respondents.id = smerf_forms_surveyrespondents.surveyrespondent_id join smerf_responses on smerf_forms_surveyrespondents.id = smerf_responses.smerf_forms_surveyrespondent_id', :conditions => ["smerf_responses.question_code = ? and lower(smerf_responses.response) like lower(?)", question, target], :group => 'people.id', :having => 'smerf_forms_surveyrespondents.id = max(smerf_forms_surveyrespondents.id)', :order => 'last_name'
  end

  def GetProgramTypes
    prog_types = [['Autographing', "1"], ['Writers Workshop', "2"], ['New Pro Orientation', "3"], ['Literary Beer', "5"], ['Stroll with Stars', "6"], ['Game Show', "7"], ['Literary Tea / Kaffeklatsch', "8"], ['Program for Young Adults / Kids', "9"], ['Docent Tours', "10"], ['Book / Story Discussion Group', "11"], ['Reading', "12"], ['Teen Writing', "13"], ['Music Workshop', "14"], ['Art Workshop', "15"], ['Costume Workshop', "16"], ['Con-running Workshop', "17"], ['Demo', "18"], ['Solo Presentation', "19"], ['Panel', "20"]]
    return prog_types
  end

  def GetFreeTextQuestions
    free_text_qs = [['Topic Knowledge', 'g7q8'], ['Program Ideas / Comments', 'g93q1'], ["Topic We Don't Know About", 'g93q2'], ['Nevada Connection', 'g93q4']]
  end
end
