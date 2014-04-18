#
# This service contains utility methods related to survey functionality.
#
# NOTE: defined as a module so that we can not instantiate it.
#
module SurveyService
  
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
  def self.runReport(surveyQuery)
    
    selectStr = createSelectPart(surveyQuery.survey_query_predicates, surveyQuery.operation)
    
    query = createQuery(surveyQuery.survey_query_predicates, surveyQuery.operation)
    count = SurveyRespondentDetail.count_by_sql('SELECT count(*) ' + query[0])
    
    # logger.debug resultSet
    cols = SurveyRespondentDetail.connection.select_all("select id, question, question_type from survey_questions where id in (" + query[1].to_a.join(',') + ')')
    
    metadata = {}
    if (cols.size() > 0)
      cols.each do |c|
        metadata['r'+ query[2][c['id'].to_i].to_s] = c
      end
    end
    
    if (surveyQuery.date_order)
      # change the order by to order by the creation date
      dateOrder = ' order by hist.filled_at desc'
    else
      dateOrder = ''
    end

    resultSet = SurveyRespondentDetail.connection.select_all(createJoinPart1(surveyQuery.survey_query_predicates, metadata, query[2]) + 
                              selectStr + query[0] +
                              ' order by last_name'  +
                              createJoinPart2(surveyQuery.survey_query_predicates, metadata, query[2]) + 
                              ' left join survey_histories hist on hist.survey_id = ' + surveyQuery.survey_id.to_s + ' and hist.survey_respondent_detail_id = res.id' + dateOrder
                               )

    # it would be good to also get the person's address (country) if there is a corresponding survey_respondent and person ...
    # oid in the result set is the survey_respondent_details
    resDetails = SurveyRespondentDetail.find_all_by_id  resultSet.collect{ |r| r['oid'] }, :include => { :survey_respondent => {:person => :postal_addresses} },
                                                    :conditions => {"postal_addresses.isdefault" => true}

    resultMap = {}
    resDetails.map { |r| resultMap[r.id] = r}
                                                        
    # Now we need to append the address information to the result set !!
    resultSet.collect { |a| 
            a.tap { |r|
              r['country'] = ( resultMap[r['oid']] ) ? resultMap[r['oid']].survey_respondent.person.postal_addresses[0].city + ', ' + resultMap[r['oid']].survey_respondent.person.postal_addresses[0].country : ''
            }
          }
    
    { :meta_data => metadata, :result_set => resultSet, :count => count }
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
    
    Person.all :joins => {:survey_respondent => {:survey_respondent_detail => {:survey_responses => {:survey_question => :survey_answers}}}},
            :conditions => ["survey_answers.answertype_id = ? AND survey_answers.answer = survey_responses.response", AnswerType['DoNotShareEmail'].id]
    
  end

  #
  # Get all people who responded to survey
  #
  def self.findPeopleWhoRespondedToSurvey(survey_name)
    survey = Survey.where("surveys.alias" => survey_name).first
    respondent_detail = SurveyRespondentDetail.includes(:survey_responses).where('survey_responses.survey_id' => survey.id)

    Person.all  :include => {:survey_respondent => :survey_respondent_detail},
                :conditions => ["survey_respondent_details.id in (?)", respondent_detail],
                :order => 'people.last_name, people.first_name'
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
  #
  #
  def self.getSurveyBio(person_id)

    SurveyResponse.first :joins => {:survey_respondent_detail => {:survey_respondent => :person}}, :conditions => {:isbio => true, :people => {:id => person_id}}
    
  end
  
  #
  # For a given person find the value for the mapped question if there is an answer...
  # TODO - we may want to restrict this to a particular survey?
  #
  def self.getValueOfMappedQuestion(person, questionMapping)
    
    # Get the first value that maps to the question...
    response = SurveyResponse.first :joins => [:survey_question, {:survey_respondent_detail => {:survey_respondent => :person}}],
      :conditions => ["survey_questions.questionmapping_id = ? and people.id = ?", questionMapping.id, person.id]
    
    response.response if response
  end

private

  def self.createJoinPart1(queryPredicates, metadata, mapping)
    tz_offset = Time.zone.formatted_offset # number of hours offset for the application timezone TODO - use the time zone of the convention

    selectPart = 'select @rownum:=@rownum+1 as id, res.id as oid, ' +
                  "DATE_FORMAT(CONVERT_TZ(hist.filled_at,'-00:00','"+ tz_offset + "'), '%h:%i %p, %d %M %Y')" +
                  ' as filled_at, ' +
                  'res.first_name, res.last_name, res.suffix, res.email, res.survey_respondent_id'
    questionIds = Set.new
    
    if (queryPredicates)
      queryPredicates.each  do |subclause|
        # if  metadata['r' + nbrOfResponse.to_s]
        if !questionIds.include?(subclause["survey_question_id"].to_i)
          selectPart += ', res.q' +  mapping[subclause["survey_question_id"]].to_s
          
          if ((metadata['r' + mapping[subclause["survey_question_id"]].to_s]['question_type'].include? "singlechoice"))
            selectPart += ', IFNULL(a' + mapping[subclause["survey_question_id"]].to_s + '.answer,res.r' + mapping[subclause["survey_question_id"]].to_s + ') as r' +  mapping[subclause["survey_question_id"]].to_s
          else  
            selectPart += ', res.r' + mapping[subclause["survey_question_id"]].to_s + ' as r' +  mapping[subclause["survey_question_id"]].to_s
          end
          questionIds.add(subclause["survey_question_id"].to_i)
        end
      end
    end
    
    return selectPart + ' from (SELECT @rownum:=0) rn, ( '
  end

  def self.createJoinPart2(queryPredicates, metadata, mapping)
    result = ' ) res '
    questionIds = Set.new

    if (queryPredicates)
      queryPredicates.each  do |subclause|
        # if  metadata['r' + nbrOfResponse.to_s]
        if !questionIds.include?(subclause["survey_question_id"].to_i)
          if ((metadata['r' + mapping[subclause["survey_question_id"]].to_s]['question_type'].include? "singlechoice"))
            result += ' left join survey_answers a' + mapping[subclause["survey_question_id"]].to_s + ' on a' + mapping[subclause["survey_question_id"]].to_s + '.id = res.r' + mapping[subclause["survey_question_id"]].to_s
          end
          questionIds.add(subclause["survey_question_id"].to_i)
        end
      end
    end
    
    return result
  end
  
  def self.createSelectPart(queryPredicates, operation)
    selectPart = 'SELECT d.id, d.first_name, d.last_name, d.suffix, d.email, d.survey_respondent_id'
    nbrOfResponse = 1
    questionIds = Set.new

    if (queryPredicates)
      queryPredicates.each  do |subclause|
        # select part
        if !questionIds.include?(subclause["survey_question_id"])
          selectPart += ', r' + nbrOfResponse.to_s + '.survey_question_id as q' +  nbrOfResponse.to_s 
          selectPart += ', r' + nbrOfResponse.to_s + '.response as r' + nbrOfResponse.to_s
          questionIds.add(subclause["survey_question_id"])
        
          nbrOfResponse += 1
        end
      end
    end  
    
    return selectPart
  end

  def self.createQuery(queryPredicates, operation)
    fromPart = ' FROM survey_respondent_details d'
    wherePart = ' WHERE '
    andPart = ' AND ('
    nbrOfResponse = 1
    questionIds = Set.new
    mapping = {}

    if (queryPredicates)
      lastid = queryPredicates.count() 
      queryPredicates.each  do |subclause|
        op = mapToOperator(subclause['operation'])
        
        # where part
        if !questionIds.include?(subclause["survey_question_id"].to_i)
          # from part
          fromPart += ', survey_responses as r' + nbrOfResponse.to_s
          
          wherePart += ' AND ' if nbrOfResponse > 1
          wherePart += 'r' + nbrOfResponse.to_s + '.survey_respondent_detail_id = d.id AND r' + nbrOfResponse.to_s + ".survey_question_id = '" + subclause["survey_question_id"].to_s + "'"
          questionIds.add(subclause["survey_question_id"].to_i)
          
          # andPart
          andPart += (operation == 'ALL') ? ' AND ' : ' OR ' if nbrOfResponse > 1
          andPart += 'r' + nbrOfResponse.to_s + ".response " + op[0]
          andPart += " '"
          andPart += "%" if (op[1] == true && op[2] == false)
          andPart += subclause["value"] if (op[1] == true)
          andPart += "%" if (op[1] == true && op[2] == false)
          andPart += "'"
          
          mapping[subclause["survey_question_id"]] = nbrOfResponse
        
          nbrOfResponse += 1
        else
          # andPart
          andPart += (operation == 'ALL') ? ' AND ' : ' OR ' if nbrOfResponse > 1
          andPart += 'r' + mapping[subclause["survey_question_id"]].to_s + ".response " + op[0] 
          andPart += " '"
          andPart += "%" if (op[1] == true && op[2] == false)
          andPart += subclause["value"] if (op[1] == true)
          andPart += "%" if (op[1] == true && op[2] == false)
          andPart += "'"
        end
        
      end
    end  
    
    return [fromPart + wherePart + andPart + ')', questionIds, mapping]
  end
 
  #
  # Given a string that represents an operation, return a triple that provides more information about the op and can be used
  # to generate the SQL
  #
  def self.mapToOperator(operation)
    op = ''
    useValue = true
    noWildcard = false

    case operation
    when 'does not contain'
      op = ' not like '
    when 'answered'
      op = " != '' "
      useValue = false
    when 'not answered'
      op = " = '' "
      useValue = false
    when 'is not'
      op = " != "
      noWildcard = true
    when 'is'
      op = " = "
      noWildcard = true
    else
      op = ' like '
    end

    return [op, useValue, noWildcard]    
  end
    
end
