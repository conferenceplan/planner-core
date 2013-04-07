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
  
  def questions
    surveyId = params[:survey]
    
    questions = SurveyQuestion.all :joins => {:survey_group => :survey},
                :conditions => {:surveys => {:id => surveyId}}
    
    ActiveRecord::Base.include_root_in_json = false
    # (:only => [ :id, :question, :question_type, :mandatory, :answer_type, :isbio, :survey_group, :sort_order ]), 
    render_json questions.to_json(:only => [ :id, :name, :question, :question_type, :mandatory, :answer_type, :isbio, :survey_group, :sort_order ],
                                  :include => {:survey_group => {}}
                                ), :content_type => 'application/json'
  end
  
  def runReport
    q = params[:query]
    j = ActiveSupport::JSON
    queryArg = j.decode(q)
    
    selectStr = createSelectPart(queryArg["queryPredicates"], queryArg["operation"])
    logger.debug selectStr
    query = createQuery(queryArg["queryPredicates"], queryArg["operation"])
    count = SurveyRespondentDetail.count_by_sql('SELECT count(*) ' + query[0])
    
    resultSet = SurveyRespondentDetail.connection.select_all(selectStr + query[0] + ' order by last_name') #ActiveRecord::Base.connection.select_rows(query)
    
    # logger.debug resultSet
    cols = SurveyRespondentDetail.connection.select_all("select id, question, question_type from survey_questions where id in (" + query[1].to_a.join(',') + ')')
    
    metadata = {}
    if (cols.size() > 0)
      cols.each do |c|
        metadata['r'+ query[2][c['id']].to_s] = c
      end
    end
    
    ActiveRecord::Base.include_root_in_json = false # TODO - check that this is safe, and a better place to put it

    render_json '{ "id" : 1, "totalpages": 1, "currpage": 1, "totalrecords": ' + count.to_s + ', "userdata": ' + metadata.to_json() + ', "rowdata": ' + resultSet.to_json() + '}',
               :content_type => 'application/json'
  end
  
  def createSelectPart(queryPredicates, operation)
    selectPart = 'SELECT d.id, d.first_name, d.last_name, d.suffix, d.survey_respondent_id'
    nbrOfResponse = 1
    questionIds = Set.new

    if (queryPredicates)
      queryPredicates.each  do |subclause|
        # select part
        if !questionIds.include?(subclause["question_id"])
        selectPart += ', r' + nbrOfResponse.to_s + '.survey_question_id as q' +  nbrOfResponse.to_s + ', r' + nbrOfResponse.to_s + '.response as r' + nbrOfResponse.to_s
        questionIds.add(subclause["question_id"])
        
        nbrOfResponse += 1
        end
      end
    end  
    
    return selectPart
  end

  # TODO - change generated query so that if the two clauses are for the same filed we do not need to add to the fromPart
  # TODO - we need to return meta information
  def createQuery(queryPredicates, operation)
    # selectPart = 'SELECT d.id, d.first_name, d.last_name, d.suffix, d.survey_respondent_id'
    fromPart = ' FROM survey_respondent_details d'
    wherePart = ' WHERE '
    andPart = ' AND ('
    nbrOfResponse = 1
    questionIds = Set.new
    mapping = {}

    if (queryPredicates)
      queryPredicates.each  do |subclause|
        # select part
        # selectPart += ', r' + nbrOfResponse.to_s + '.survey_question_id as q' +  nbrOfResponse.to_s + ', r' + nbrOfResponse.to_s + '.response as r' + nbrOfResponse.to_s
        
        # where part
        if !questionIds.include?(subclause["question_id"])
          # from part
          fromPart += ', survey_responses as r' + nbrOfResponse.to_s
        
          wherePart += ' AND ' if nbrOfResponse > 1
          wherePart += 'r' + nbrOfResponse.to_s + '.survey_respondent_detail_id = d.id AND r' + nbrOfResponse.to_s + ".survey_question_id = '" + subclause["question_id"].to_s + "'"
          questionIds.add(subclause["question_id"])
          
          # andPart
          andPart += (operation == 'ALL') ? ' AND ' : ' OR ' if nbrOfResponse > 1
          andPart += 'r' + nbrOfResponse.to_s + ".response like '%" + subclause["value"] + "%'" # TODO - change like depending on operator
          
          mapping[subclause["question_id"]] = nbrOfResponse
        
          nbrOfResponse += 1
        else
          # andPart
          andPart += (operation == 'ALL') ? ' AND ' : ' OR ' if nbrOfResponse > 1
          andPart += 'r' + (nbrOfResponse -1).to_s + ".response like '%" + subclause["value"] + "%'" # TODO - change like depending on operator
        end
        
      end
    end  
    
    return [fromPart + wherePart + andPart + ')', questionIds, mapping]
  end

  def createClauses(queryPredicates, operation)
    clause = nil
    fields = Array::new
    
    if (queryPredicates)
      clausestr = ""
      queryPredicates.each  do |subclause|
        if clausestr.length > 0 
          # if operation == 'ALL'
            # clausestr << ' ' + 'AND' + ' '
          # else
            # clausestr << ' ' + 'OR' + ' '
          # end
          clausestr << ' ' + 'OR' + ' '
        end
        clausestr << "("
        clausestr << "survey_question_id = ? AND "
        if subclause["operation"] == 'contains'
          clausestr << "response like ? "
        elsif subclause[operation] == 'does not contain' 
          clausestr << "response not like ? "
        end
        clausestr << ")"

        fields << subclause["question_id"]
        fields << '%' + subclause["value"] + '%'
      end
      # logger.debug fields
      clause = [clausestr] + fields
    end
    
    # logger.debug clause
    
    return clause
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
