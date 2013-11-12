#
#
#
class SurveyReportsController < PlannerController
  
  def index
  end
  
  # Get a list of the names of the surveys and return this as a JSON structure  
  # def surveyNames
    # surveys = Survey.all
#     
    # ActiveRecord::Base.include_root_in_json = false # TODO - this is not the most elegent way to set it since it has a side-effect
    # render json: surveys.to_json(:only => [ :id, :name ]), :content_type => 'application/json'
  # end
#   
  # def surveyQueryNames
    # # TODO - either get the queries for current user or get the queries that are shared
    # if (params[:myQueries])
      # queries = SurveyQuery.all :conditions => {:user_id => @current_user, :shared => false}
    # else  
      # queries = SurveyQuery.all :conditions => {:shared => true}
    # end
#     
    # ActiveRecord::Base.include_root_in_json = false
# 
    # render json: queries.to_json(:only => [ :id, :name, :shared ]), :content_type => 'application/json'
  # end
#   
  # def delSurveyQuery
    # # delete the survey query with the id passed in
    # survey = SurveyQuery.find(params[:id])
    # survey.destroy
#     
    # # and return the remaining list of surveys
    # queries = SurveyQuery.all
#     
    # ActiveRecord::Base.include_root_in_json = false
# 
    # render json: queries.to_json(:only => [ :id, :name, :shared ]), :content_type => 'application/json'
  # end
  
  # def questions
    # surveyId = params[:survey]
#     
    # # TODO - use the group and question ordering
    # questions = SurveyQuestion.all :joins => {:survey_group => :survey}, :include => :survey_answers,
                # :conditions => {:surveys => {:id => surveyId}, :question_type => ['textfield', 'textbox', 'singlechoice', 'multiplechoice', 'selectionbox', 'availability']}
#     
    # ActiveRecord::Base.include_root_in_json = false
# 
    # render json: questions.to_json(:only => [ :id, :name, :question, :question_type, :mandatory, :answer_type, :isbio, :survey_group, :sort_order, :answer ],
                                  # :include => {:survey_group => {}, :survey_answers => {}}
                                # ), :content_type => 'application/json'
  # end

  #
  #
  #  
  def runReport
    # Get the query from the database i.e. we receive the id of the query
    surveyQuery = SurveyQuery.find params[:query_id]
    
    result = SurveyService.runReport(surveyQuery)    
    
    render json: '{ "totalpages": 1, "currpage": 1, "totalrecords": ' + result[:count].to_s + 
                  ', "userdata": ' + result[:meta_data].to_json() + 
                  ', "rowdata": ' + result[:result_set].to_json() + '}',
                  :content_type => 'application/json'
  end
  
  def missing_bio
    @missing_bio = Person.all :joins => {:survey_respondent => {:survey_respondent_detail => :survey_responses}}, 
                :include => :edited_bio,
                :conditions => {:survey_responses => {:isbio => true}, :edited_bios => { :person_id => nil} },
                :order => "people.last_name ASC"
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
 
  # def available_during
    # @conflicts = GetConflictItems()
    # if params[:conflict_id]
      # (q_id, target) = params[:conflict_id].split('|')
      # @names = search_survey_negative(q_id, target)
    # end
  # end

  # def panelists_with_metadata
    # @names = []
  # end

end
