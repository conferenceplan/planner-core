#
#
#
class SurveyReportsController < PlannerController
  include PlannerReportHelpers
  
  def index
  end
  
  # Get a list of the names of the surveys and return this as a JSON structure  
  def surveyNames
    surveys = Survey.all
    
    ActiveRecord::Base.include_root_in_json = false # TODO - this is not the most elegent way to set it since it has a side-effect
    render_json surveys.to_json(:only => [ :id, :name ]), :content_type => 'application/json'
  end
  
  def surveyQueryNames
    # TODO - either get the queries for current user or get the queries that are shared
    queries = SurveyQuery.all
    
    ActiveRecord::Base.include_root_in_json = false

    render_json queries.to_json(:only => [ :id, :name, :shared ]), :content_type => 'application/json'
  end
  
  def delSurveyQuery
    # delete the survey query with the id passed in
    survey = SurveyQuery.find(params[:id])
    survey.destroy
    
    # and return the remaining list of surveys
    queries = SurveyQuery.all
    
    ActiveRecord::Base.include_root_in_json = false

    render_json queries.to_json(:only => [ :id, :name, :shared ]), :content_type => 'application/json'
  end
  
  def questions
    surveyId = params[:survey]
    
    # TODO - use the group and question ordering
    questions = SurveyQuestion.all :joins => {:survey_group => :survey}, :include => :survey_answers,
                :conditions => {:surveys => {:id => surveyId}, :question_type => ['textfield', 'textbox', 'singlechoice', 'multiplechoice', 'selectionbox', 'availability']}
    
    ActiveRecord::Base.include_root_in_json = false

    render_json questions.to_json(:only => [ :id, :name, :question, :question_type, :mandatory, :answer_type, :isbio, :survey_group, :sort_order, :answer ],
                                  :include => {:survey_group => {}, :survey_answers => {}}
                                ), :content_type => 'application/json'
  end
  
  def runReport
    q = params[:query]
    j = ActiveSupport::JSON
    queryArg = j.decode(q)
    
    selectStr = createSelectPart(queryArg["survey_query_predicates"], queryArg["operation"])
    logger.debug selectStr
    query = createQuery(queryArg["survey_query_predicates"], queryArg["operation"])
    count = SurveyRespondentDetail.count_by_sql('SELECT count(*) ' + query[0])
    
    # logger.debug resultSet
    cols = SurveyRespondentDetail.connection.select_all("select id, question, question_type from survey_questions where id in (" + query[1].to_a.join(',') + ')')
    
    metadata = {}
    if (cols.size() > 0)
      cols.each do |c|
        metadata['r'+ query[2][c['id'].to_i].to_s] = c
      end
    end

    resultSet = SurveyRespondentDetail.connection.select_all(createJoinPart1(queryArg["survey_query_predicates"], metadata, query[2]) + selectStr + query[0] + ' order by last_name' + createJoinPart2(queryArg["survey_query_predicates"], metadata, query[2]))
    
    ActiveRecord::Base.include_root_in_json = false # TODO - check that this is safe, and a better place to put it

    render_json '{ "totalpages": 1, "currpage": 1, "totalrecords": ' + count.to_s + ', "userdata": ' + metadata.to_json() + ', "rowdata": ' + resultSet.to_json() + '}',
               :content_type => 'application/json'
  end
  
  def createJoinPart1(queryPredicates, metadata, mapping)
    selectPart = 'select @rownum:=@rownum+1 as id, res.id as oid, res.first_name, res.last_name, res.suffix, res.email, res.survey_respondent_id'
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

  def createJoinPart2(queryPredicates, metadata, mapping)
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
  
  def createSelectPart(queryPredicates, operation)
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

  def createQuery(queryPredicates, operation)
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
        logger.debug op
        
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
  
  def mapToOperator(operation)
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

  def library_talks
    @library_talkers = Person.all :joins => {:survey_respondent => {:survey_respondent_detail => {:survey_responses => :survey_question}}}, 
                :conditions => {:survey_questions => {:id => 73}, :survey_responses => {:response => 'I am willing to do a reading or a talk at a local library.'}},
                :order => "people.last_name ASC"
  end
 
  def interviewable
    @interviewable = Person.all :joins => {:survey_respondent => {:survey_respondent_detail => {:survey_responses => :survey_question}}}, 
                :conditions => {:survey_questions => {:id => 73}, :survey_responses => {:response => 'I am willing to be interviewed by the media.'}},
                :order => "people.last_name ASC"
  end
 
  def missing_bio
    @missing_bio = Person.all :joins => {:survey_respondent => {:survey_respondent_detail => :survey_responses}}, 
                :include => :edited_bio,
                :conditions => {:survey_responses => {:isbio => true}, :edited_bios => { :person_id => nil} },
                :order => "people.last_name ASC"
  end

  # TODO - these are a temp queries for LSC  
  def moderators
    @moderators = Person.all :joins => {:survey_respondent => {:survey_respondent_detail => {:survey_responses => :survey_question}}}, 
                :conditions => {:survey_questions => {:id => 56}, :survey_responses => {:response => 55}},
                :order => "people.last_name ASC"
  end
 
  def music_night
    @music_night = Person.all :select => "people.*, survey_responses.response",
                :joins => {:survey_respondent => {:survey_respondent_detail => {:survey_responses => :survey_question}}}, 
                :conditions => "survey_questions.id = 61 AND survey_responses.response <> ''", #{:survey_questions => {:id => 61}, :survey_responses => {:response => '' }},
                :order => "people.last_name ASC"
  end

  def art_night
    @art_night = Person.all :select => "people.*, survey_responses.response",
                :joins => {:survey_respondent => {:survey_respondent_detail => {:survey_responses => :survey_question}}}, 
                :conditions => "survey_questions.id = 62 AND survey_responses.response <> ''", #{:survey_questions => {:id => 61}, :survey_responses => {:response => '' }},
                :order => "people.last_name ASC"
  end

  def program_types
    # @program_types = GetProgramTypes()
    # @interested = search_survey_exact('g9q1', params[:type_id])
  end
 
  def free_text
    # @free_text_qs = GetFreeTextQuestions()
    # if params[:q_id]
      # search_string = '%'+params[:search_string]+'%'
      # @names = search_survey(params[:q_id], search_string)
    # end
  end
  
  def tags_by_context
    taggings = ActsAsTaggableOn::Tagging.find :all,
                  :select => "DISTINCT(context)",
                  :conditions => "taggable_type like 'Person'"
                  
    @contexts = Array.new

    # for each context get the set of tags (sorted), and add them to the collection for display on the page
    taggings.each do |tagging|
      @contexts << tagging.context
    end

    if params[:tag]
      logger.debug params[:tag][:context]
      @context = params[:tag][:context]
      
      @names = Person.all(:joins => "INNER JOIN taggings ON taggings.taggable_type = 'Person' AND taggings.taggable_id = people.id AND taggings.context = '" + @context +"'",
                    :select => "DISTINCT people.* ",
                    :order => "people.last_name ASC")
    end
  end
 
  def available_during
    # @conflicts = GetConflictItems()
    # if params[:conflict_id]
      # (q_id, target) = params[:conflict_id].split('|')
      # @names = search_survey_negative(q_id, target)
    # end
  end

  def panelists_with_metadata
    @names = []
  end

end
