class SurveyQueryController < PlannerController
  
  def index
    @queries = SurveyQuery.all
  end
  
  def list
    # TODO - add a parameter so we can filter based on public and user queries
    # TODO - if no user specified then return only the public queries
    @queries = SurveyQuery.all
  end


  def show
    @query = SurveyQuery.find(params[:id])
  end
  
  def create
    # # TODO - make sure name is unique
    # p = params.reject{|k, v| ['action', 'controller'].include?(k) } # remove the unwanted attributes from the parameters
    # p['survey_query_predicates_attributes'] = p['survey_query_predicates']
    # p.delete('survey_query_predicates')
    # need to pass in survey_query_predicates_attributes
    @query = SurveyQuery.new(params[:survey_query]) # and then save the query
    @query.user = @current_user
    @query.save
  end

  def update
    # get the survey
    @query = SurveyQuery.find(params[:id])
    
    # # and then update it's attributes
    # p = params.reject{|k, v| ['action', 'controller', 'updated_at', 'created_at', 'lock_version', 'id'].include?(k) }
    # p['survey_query_predicates_attributes'] = p['survey_query_predicates']
    # p.delete('survey_query')
    # p.delete('survey_query_predicates')
    @query.update_attributes(params[:survey_query])
  end

  def destroy
    query = SurveyQuery.find(params[:id])
    
    # Test to make sure that the person requesting the delete owns the query
    if (query.user == @current_user)
      query.destroy
      render status: :ok, text: {}.to_json
    else
      render status: :bad_request, text: 'Con not delete query owned by another user'
    end
  end

end
