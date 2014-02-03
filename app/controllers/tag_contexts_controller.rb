class TagContextsController < PlannerController
  
  def index
    tag_contexts = TagContext.all

    render json: tag_contexts.to_json, :content_type => 'application/json'
  end

  def show
    tag_context = TagContext.find(params[:id])

    render json: tag_context.to_json, :content_type => 'application/json'
  end

  def create
    # Make sure that the context does not contain a space
    str = params[:tag_context]
    str['name'] = str['name'].gsub(/ /,'_')
    
    tag_context = TagContext.new(str)
    tag_context.save!

    render json: tag_context.to_json, :content_type => 'application/json'
  end

  def update
    tag_context = TagContext.find(params[:id])
    tag_context.update_attributes(params[:tag_context])

    render json: tag_context.to_json, :content_type => 'application/json'
  end

  def destroy
    tag_context = TagContext.find(params[:id])

    if ((Person.tag_counts_on(tag_context.name).size > 0) || (ProgrammeItem.tag_counts_on(tag_context.name).size > 0))
      render status: :bad_request, text: 'Unable to context as it is in use'
    else
      tag_context.destroy
      render status: :ok, text: {}.to_json
    end
  end
end
