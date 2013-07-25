class SurveyQueryController < PlannerController
  def index
    logger.debug "index"
  end

  def show
    query = SurveyQuery.find(params[:id])
    
    ActiveRecord::Base.include_root_in_json = false # TODO - check that this is safe, and a better place to put it

    render json: query.to_json(:include => {:survey_query_predicates => {}},
      :except => [:created_at, :updated_at, :lock_version]
      ), :content_type => 'application/json' # need to return the model so that the client has the id
  end
  
  def new
  end
  
  def create
    # todo - make sure name is unique
    p = params.reject{|k, v| ['action', 'controller'].include?(k) } # remove the unwanted attributes from the parameters
    p['survey_query_predicates_attributes'] = p['survey_query_predicates']
    p.delete('survey_query_predicates')
    # need to pass in survey_query_predicates_attributes
    query = SurveyQuery.new(p) # and then save the query
    query.user = @current_user
    query.save
    
    ActiveRecord::Base.include_root_in_json = false # TODO - check that this is safe, and a better place to put it

    render json: query.to_json(:include => {:survey_query_predicates => {}}, 
          :except => [:created_at, :updated_at, :lock_version]),
    :content_type => 'application/json' # need to return the model so that the client has the id
  end

  def edit
  end
  
  def update
    # get the survey
    query = SurveyQuery.find(params[:id])
    
    # and then update it's attributes
    p = params.reject{|k, v| ['action', 'controller', 'updated_at', 'created_at', 'lock_version', 'id'].include?(k) }
    p['survey_query_predicates_attributes'] = p['survey_query_predicates']
    p.delete('survey_query')
    p.delete('survey_query_predicates')
    query.update_attributes(p)
    
    ActiveRecord::Base.include_root_in_json = false # TODO - check that this is safe, and a better place to put it

    render json: query.to_json(:include => {:survey_query_predicates => {}},
      :except => [:created_at, :updated_at, :lock_version]
      ), :content_type => 'application/json' # need to return the model so that the client has the id
  end

  def destroy
  end

end
