#
# This service contains utility methods related to survey functionality.
#
# NOTE: defined as a module so that we can not instantiate it.
#
module SurveyService

  #
  #
  #
  def self.updateBioTextFromSurvey(sinceDate = nil)
    bioQuestion = SurveyQuestion.where(:isbio => true).order("created_at desc").first

    Person.transaction do
      people = SurveyService.findPeopleWhoAnsweredBio(sinceDate)
      
      people.each do |person|
        person.edited_bio = EditedBio.new(:person_id => person.id) if !person.edited_bio
        surveyResponse = SurveyService.findResponseToQuestionForPerson(bioQuestion,person,sinceDate)[0]

        if surveyResponse && !(surveyResponse.response.blank?) && person.edited_bio.bio.blank?
          person.edited_bio.bio = surveyResponse.response
          person.edited_bio.save!
        end
      end
    end
  end
  
  #
  # Update twitter etc from the survey... need to be able to check against the bio info so as to not overwrite edits
  #
  def self.updatePersonBioFromSurvey(sinceDate = nil)
    Person.transaction do
      # Get the response from the survey
      # If the response is newer that the info in the Bio then update the Bio
      websiteQuestion = SurveyQuestion.where(:questionmapping_id => QuestionMapping['WebSite']).order("created_at desc")
      twitterQuestion = SurveyQuestion.where(:questionmapping_id => QuestionMapping['Twitter']).order("created_at desc")
      otherQuestion = SurveyQuestion.where(:questionmapping_id => QuestionMapping['OtherSocialMedia']).order("created_at desc")
      photoQuestion = SurveyQuestion.where(:questionmapping_id => QuestionMapping['Photo']).order("created_at desc")
      faceQuestion = SurveyQuestion.where(:questionmapping_id => QuestionMapping['Facebook']).order("created_at desc")

      setResponse('website', websiteQuestion,sinceDate) if websiteQuestion
      setResponse('twitterinfo', twitterQuestion,sinceDate) if twitterQuestion
      setResponse('othersocialmedia', otherQuestion,sinceDate) if otherQuestion
      if photoQuestion && photoQuestion.size > 0
        setResponse('photourl', photoQuestion,sinceDate) if photoQuestion && (photoQuestion[0].question_type == :textfield)
      end
      setResponse('facebook', faceQuestion,sinceDate) if faceQuestion
    end
  end

  #
  #
  #
  def self.findAnswersForExcludedItems
    SurveyAnswer.find :all, :include => :programme_items, :conditions => ['answertype_id = ?', AnswerType['ItemConflict'].id], :order => 'answer'
  end

  #
  #
  #
  def self.findAnswersForExcludedTimes
    SurveyAnswer.find :all,  :conditions => ['answertype_id = ?', AnswerType['TimeConflict'].id]
  end
  
  #
  #
  #
  def self.findQuestionForMaxItemsPerDay
    SurveyQuestion.find :first, :conditions => ['questionmapping_id = ?', QuestionMapping['ItemsPerDay'].id] # There should only be one
  end

  #
  #
  #
  def self.findQuestionForMaxItemsPerCon
    SurveyQuestion.find :first, :conditions => ['questionmapping_id = ?', QuestionMapping['ItemsPerConference'].id] # There should only be one
  end

  #
  #
  #  
  def self.executeReport(surveyQuery)
    query = constructQuery(surveyQuery.survey_query_predicates, surveyQuery.operation)
    
    SurveyRespondentDetail.joins(:survey_responses, :survey_histories).
                            includes([:survey_histories, :survey_responses, {:survey_respondent => {:person => :postal_addresses}}]).
                            where(query).
                            where("survey_histories.survey_id = ?", surveyQuery.survey_id).
                            order("survey_respondent_details.last_name, survey_respondent_details.first_name")
    
  end
  
  #
  # Given the id of a person return the surveys that that person has responded to
  #
  def self.findSurveysForPerson(person_id)
    
    Survey.includes(:survey_responses => {:survey_respondent_detail => {:survey_respondent => :person}} ).where("people.id" => person_id)
    
  end

  #
  # Get all the people who said that they do not want to share their email with other participants
  #  
  def self.findPeopleWithDoNotShareEmail
    
    # Person.all :joins => {:survey_respondent => {:survey_respondent_detail => {:survey_responses => {:survey_question => :survey_answers}}}},
            # :conditions => ["survey_answers.answertype_id = ? AND survey_answers.answer = survey_responses.response", AnswerType['DoNotShareEmail'].id]
            
    Person.joins({:survey_respondent => {:survey_respondent_detail => {:survey_responses => {:survey_question => :survey_answers}}}}).
            where(["survey_answers.answertype_id = ? AND survey_answers.id = survey_responses.response", AnswerType['DoNotShareEmail'].id]).
            where(self.constraints())

  end

  #
  # Get all people who responded to survey
  #
  def self.findPeopleWhoRespondedToSurvey(survey_name)
    survey = Survey.where("surveys.alias" => survey_name).first
    respondent_detail = SurveyRespondentDetail.includes(:survey_responses).where('survey_responses.survey_id' => survey.id)

    # Person.all  :include => {:survey_respondent => :survey_respondent_detail},
                # :conditions => ["survey_respondent_details.id in (?)", respondent_detail],
                # :order => 'people.last_name, people.first_name'
    
    Person.where(["survey_respondent_details.id in (?)", respondent_detail]).
            include({:survey_respondent => :survey_respondent_detail}).
            where(self.constraints()).
            order('people.last_name, people.first_name')

  end
  
  #
  #
  #
  def self.personAnsweredSurvey(person, survey_alias)
    nbr = SurveyResponse.count :joins => [{:survey_question => {:survey_group => :survey}}, {:survey_respondent_detail => {:survey_respondent => :person}}],
      :conditions => ["people.id = ? && surveys.alias = ?", person.id, survey_alias]
      
    nbr > 0
  end
  
  #
  #
  #
  def self.personHasSurveys(person)
    nbr = SurveyResponse.joins([{:survey_question => {:survey_group => :survey}}, {:survey_respondent_detail => {:survey_respondent => :person}}]).
            where(["people.id = ?", person.id]).
            where(self.constraints()).count
    nbr > 0
  end
  
  #
  #
  #
  def self.findPeopleWhoGaveAnswer(answer, sinceDate = nil)
    
    conditions = ["survey_responses.survey_question_id = ? and lower(survey_responses.response) like lower(?)", answer.survey_question_id, answer.answer]
    if (sinceDate)
      conditions[0] += " AND (survey_responses.updated_at > ? OR survey_answers.updated_at > ?)"
      conditions << sinceDate
      conditions << sinceDate
    end
    
    Person.joins({:survey_respondent => {:survey_respondent_detail => {:survey_responses => {:survey_question => :survey_answers}}}}).
          where(conditions).
          where(self.constraints()).
          order('last_name, first_name')
  end
  
  #
  # For a given answer find the people who did not provide any response
  #
  def self.findPeopleWhoDidNotGiveAnswer(answer)
    Person.joins({:survey_respondent => :survey_respondent_detail}).
           joins("left join survey_responses on survey_responses.survey_respondent_detail_id = survey_respondent_details.id and survey_responses.response = '" + 
                                      answer.answer + "'").
           where("survey_responses.id is null").
           where(self.constraints()).
           order('last_name, first_name')
  end
  
  #
  #
  #
  def self.findPeopleWhoAnsweredQuestion(question, sinceDate = nil)
    
    conditions = ["survey_responses.survey_question_id = ?", question.id]
    if (sinceDate)
      conditions[0] += " AND (survey_responses.updated_at > ? OR survey_questions.updated_at > ?)"
      conditions << sinceDate
      conditions << sinceDate
    end
    
    Person.joins({:survey_respondent => {:survey_respondent_detail => {:survey_responses => :survey_question}}}).
            where(conditions).
            where(self.constraints()).
            order('last_name, first_name')
      
  end
  
  #
  #
  #
  def self.findPeopleWhoAnsweredQuestions(questions, sinceDate = nil)
    
    conditions = ["survey_responses.survey_question_id in (?)", questions.collect{|q| q.id}]
    if (sinceDate)
      conditions[0] += " AND (survey_responses.updated_at > ? OR survey_questions.updated_at > ?)"
      conditions << sinceDate
      conditions << sinceDate
    end
    
    Person.joins({:survey_respondent => {:survey_respondent_detail => {:survey_responses => :survey_question}}}).
            where(conditions).
            where(self.constraints()).
            order('last_name, first_name')
      
  end
  
  #
  #
  #
  def self.findPeopleWhoAnsweredBio(sinceDate = nil)
    
    conditions = ["survey_questions.isbio = 1"]
    if (sinceDate)
      conditions[0] += " AND (survey_responses.updated_at > ? OR survey_questions.updated_at > ?)"
      conditions << sinceDate
      conditions << sinceDate
    end
    
    Person.joins({:survey_respondent => {:survey_respondent_detail => {:survey_responses => :survey_question}}}).
            where(conditions).
            where(self.constraints())
      
  end
  
  #
  #
  #
  def self.findResponseToQuestionForPerson(question, person, sinceDate = nil)
    
    if question
      conditions = ["survey_responses.survey_question_id = ? and people.id = ? ", question.id, person.id]
      if (sinceDate)
        conditions[0] += " AND (survey_responses.updated_at > ? OR survey_questions.updated_at > ?)"
        conditions << sinceDate
        conditions << sinceDate
      end
      
      SurveyResponse.all :joins => [:survey_question, {:survey_respondent_detail => {:survey_respondent => :person}}],
        :conditions => conditions, :order => "created_at desc"
    else
      [nil] 
    end
         
  end
  
  #
  #
  #
  def self.findResponseToQuestionsForPerson(questions, person, sinceDate = nil)
    
    if questions
      conditions = ["survey_responses.survey_question_id in (?) and people.id = ? ", questions.collect{|q| q.id}, person.id]
      if (sinceDate)
        conditions[0] += " AND (survey_responses.updated_at > ? OR survey_questions.updated_at > ?)"
        conditions << sinceDate
        conditions << sinceDate
      end
      
      SurveyResponse.all :joins => [:survey_question, {:survey_respondent_detail => {:survey_respondent => :person}}],
        :conditions => conditions, :order => "created_at desc"
    else
      [nil] 
    end
         
  end
  
  #
  #
  #
  def self.getSurveyBio(person_id)

    SurveyResponse.first :joins => {:survey_respondent_detail => {:survey_respondent => :person}}, :conditions => {:isbio => true, :people => {:id => person_id}}, :order => "created_at desc"
    
  end
  
  #
  # For a given person find the value for the mapped question if there is an answer...
  # TODO - we may want to restrict this to a particular survey?
  #
  def self.getValueOfMappedQuestion(person, questionMapping)
    
    # Get the first value that maps to the question...
    response = SurveyResponse.joins([:survey_question, {:survey_respondent_detail => {:survey_respondent => :person}}]).
                where(["survey_questions.questionmapping_id = ? and people.id = ?", questionMapping.id, person.id]).
                where(self.constraints()).first

    response.response if response
  end
  

private
  #
  #
  #
  def self.setResponse(mapping, questions, sinceDate)
    
    people = SurveyService.findPeopleWhoAnsweredQuestions(questions, sinceDate)
    people.each do |person|
      response = SurveyService.findResponseToQuestionsForPerson(questions,person,sinceDate)[0]

      if (response && !response.response.empty?)
          person.edited_bio = EditedBio.new(:person_id => person.id) if !person.edited_bio
          person.edited_bio.send("#{mapping}=", response.response)
          person.edited_bio.save!
      end
    end
    
  end
  

  #
  # Use AREL to construct a query based on the predicates
  #
  def self.constructQuery(queryPredicates, operation)
    responseTable = Arel::Table.new(:survey_responses)
    query = nil
    
    if queryPredicates
      queryPredicates.each do |predicate|
        val = nil
        
        if predicate.survey_question.question_type == :singlechoice
          ans = predicate.survey_question.survey_answers.find { |answer| answer.answer == predicate["value"] }
          val = ans.id if ans
        else
          val = predicate["value"]
        end
        
        if val
          opAndValue = getOpAndValue(predicate["operation"], val)
          q = responseTable[:response].send(opAndValue[0],opAndValue[1]).
                        and(responseTable[:survey_question_id].eq(predicate["survey_question_id"]))
          query = query ? query.or(q) : q
        end
      end
    end
    
    query
  end
  
  #
  # Get the operation and value based on what was picked by the user
  #
  def self.getOpAndValue(operation, value)
    case operation
    when 'does not contain'
      ['does_not_match', '%' + value + '%']
    when 'answered'
      # not null and not blank
      ["not_eq_all", ['', nil]]
    when 'not answered'
      # is null or blank
      ["eq_any", ['', nil]]
    when 'is not'
      ["not_eq", value]
    when 'is'
      ["eq", value]
    else
      ['matches', '%' + value + '%']
    end
  end

  def self.constraints(*args)
    true
  end
    
end
