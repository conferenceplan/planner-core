module SurveyReportHelpers

  def search_survey_exact(question, target)
    return Person.all :select => 'people.*, smerf_responses.response', :joins => 'join survey_respondents on people.id = survey_respondents.person_id join(select surveyrespondent_id, max(id) as id from smerf_forms_surveyrespondents group by surveyrespondent_id) max_resp on survey_respondents.id = max_resp.surveyrespondent_id join smerf_responses on max_resp.id = smerf_responses.smerf_forms_surveyrespondent_id', :conditions => ["smerf_responses.question_code = ? and smerf_responses.response = ? and people.invitestatus_id = 5", question, target], :order => 'last_name'
  end

  def search_survey_negative(question, target)
    return Person.all :select => 'people.*, smerf_responses.response', :joins => "join survey_respondents on people.id = survey_respondents.person_id join (select surveyrespondent_id, max(id) as id from smerf_forms_surveyrespondents group by surveyrespondent_id) max_resp on survey_respondents.id = max_resp.surveyrespondent_id left join smerf_responses on max_resp.id = smerf_responses.smerf_forms_surveyrespondent_id and smerf_responses.question_code = '#{question}' and smerf_responses.response = '#{target}'", :conditions => ["people.invitestatus_id = 5 and smerf_responses.response is NULL"], :order => 'last_name'
  end

  def search_survey(question, target)
    return Person.all :select => 'people.*, smerf_responses.response', :joins => 'join survey_respondents on people.id = survey_respondents.person_id join (select surveyrespondent_id, max(id) as id from smerf_forms_surveyrespondents group by surveyrespondent_id) max_resp on survey_respondents.id =max_resp.surveyrespondent_id join smerf_responses on max_resp.id = smerf_responses.smerf_forms_surveyrespondent_id', :conditions => ["smerf_responses.question_code = ? and lower(smerf_responses.response) like lower(?) and people.invitestatus_id = 5", question, target], :order => 'last_name'
  end

  def GetProgramTypes
    prog_types = [['Autographing', "1"], ['Writers Workshop', "2"], ['New Pro Orientation', "3"], ['Literary Beer', "5"], ['Stroll with Stars', "6"], ['Game Show', "7"], ['Literary Tea / Kaffeklatsch', "8"], ['Program for Young Adults / Kids', "9"], ['Docent Tours', "10"], ['Book / Story Discussion Group', "11"], ['Reading', "12"], ['Teen Writing', "13"], ['Music Workshop', "14"], ['Art Workshop', "15"], ['Costume Workshop', "16"], ['Con-running Workshop', "17"], ['Demo', "18"], ['Solo Presentation', "19"], ['Panel', "20"]]
    return prog_types
  end

  def GetFreeTextQuestions
    free_text_qs = [['Topic Knowledge', 'g7q8'], ['Program Ideas / Comments', 'g93q1'], ["Topics We Don't Know About", 'g93q2'], ['Nevada Connection', 'g93q4']]
  end

  def GetTagContexts
    contexts = [['scienceItems', 'g7q1'], ['literature', 'g7q2'], ["art", 'g7q3'], ['media', 'g7q4'], ['fandom', 'g7q5'], ['nevada', 'g7q6'], ["othertopics", 'g7q7'], ["authors", 'g8q1']]
  end

  def GetConflictItems
    conflicts = [['Opening Ceremony', '1'], ['Chesley Awards', '2'], ['Masquerade', '3'], ['Hugo Ceremony', '4'], ['Closing Ceremony', '5'], ['Tricky Pixie Concert', '6'], ['WSFS Meetings', '7'], ['SFWA Meeting', '8'], ['ASFA Meeting', '9'], ['Masq Rehearssal', '10'], ['Art Auction', '11'], ['Regency Dance', '12'], ['Charity and Fan Fund Auction', '13']]
  end

end
