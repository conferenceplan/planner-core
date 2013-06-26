#
# This service contains utility methods related to survey functionality.
#
class SurveyService

  #
  # Get all the people who said that they do not want to share their email with other participants
  #  
  def self.findPeopleWithDoNotShareEmail
    
    Person.all :joins => {:survey_respondent => {:survey_respondent_detail => {:survey_responses => {:survey_question => :survey_answers}}}},
            :conditions => ["survey_answers.answertype_id = ? AND survey_answers.answer = survey_responses.response", AnswerType['DoNotShareEmail'].id]
    
  end
  
  #
  #
  #
  def self.findPeopleWhoGaveAnswer(answer, inviteStatus = InviteStatus['Invited'], acceptanceStatus = AcceptanceStatus['Accepted'], attending = true)
    
    # Put in the :select so as to over-ride the active record "read only true when a :join is used"
    Person.all :select => 'people.*',
      :joins => {:survey_respondent => {:survey_respondent_detail => :survey_responses}},
      :conditions => ["survey_responses.survey_question_id = ? and lower(survey_responses.response) like lower(?) and people.invitestatus_id = ? and people.acceptance_status_id = ? and survey_respondents.attending = ?",
        answer.survey_question_id, answer.answer, inviteStatus.id, acceptanceStatus.id, attending], 
      :order => 'last_name, first_name'
      
  end
  
  #
  #
  #
  def self.findPeopleWhoAnsweredQuestion(question, inviteStatus = InviteStatus['Invited'], acceptanceStatus = AcceptanceStatus['Accepted'], attending = true)
    
    # Put in the :select so as to over-ride the active record "read only true when a :join is used"
    Person.all :select => 'people.*',
      :joins => {:survey_respondent => {:survey_respondent_detail => :survey_responses}},
      :conditions => ["survey_responses.survey_question_id = ? and people.invitestatus_id = ? and people.acceptance_status_id = ? and survey_respondents.attending = ?",
        question.id, inviteStatus.id, acceptanceStatus.id, attending], 
      :order => 'last_name, first_name'

  end
  
  #
  #
  #
  def self.findResponseToQuestionForPerson(question, person, inviteStatus = InviteStatus['Invited'], acceptanceStatus = AcceptanceStatus['Accepted'], attending = true)
    
    SurveyResponse.all :joins => {:survey_respondent_detail => {:survey_respondent => :person}},
      :conditions => ["survey_responses.survey_question_id = ? and people.id = ? and people.invitestatus_id = ? and people.acceptance_status_id = ? and survey_respondents.attending = ?",
        question.id, person.id, inviteStatus, acceptanceStatus, attending]
         
  end
  
  #
  # Each question will have a subtype (plain, url, twitter, photo, etc that can be used to provide semantic info)
  #
  def self.findResponseToQuestionTypeForPerson(questionSubType, person)
    return '' # TODO - this should be based on the type of answer to the question i.e. time etc
  end

end
