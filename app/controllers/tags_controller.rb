class TagsController < PlannerController
  # GET /tags
  # GET /tags.xml
  def index
    # For each of the possible contexts get the tags...
    className = params[:class]
    
    # 1. Get the set of contexts
    contexts = TagContext.all
    # 2. For each context get the tags for thie person and add them to the results
    @allTagCounts = Hash.new
    contexts.each do |context|
      tags = eval(className).tag_counts_on( context.name )
      if tags != nil
        @allTagCounts[context.name] = tags
      end
    end
    
    # 3. Then pass this along to the view
    respond_to do |format|
      format.html { render :layout => 'content' } # show.html.erb
      format.xml
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  #
  # For a given class, get the object instance with the id and then get it's set of tags
  #
  def show
    # For each of the possible contexts get the tags...
    className = params[:class]
    obj = eval(className).find(params[:id])
    
    # 1. Get the set of contexts
    contexts = TagContext.all
    # 2. For each context get the tags for thie person and add them to the results
    @allTags = Hash.new
    contexts.each do |context|
      tags = obj.tag_list_on( context.name )
      if tags != nil
        @allTags[context.name] = tags
      end
    end
    
    # 3. Then pass this along to the view
    respond_to do |format|
      format.html { render :layout => 'content' } # show.html.erb
      format.xml  
    end
  end
  
  def add
    # class
    # id
    # context
    context = params[:context]
    className = params[:class]
    obj = eval(className).find(params[:id])
    tag = params[:tag]
    
    obj.tag_list_on(context).add(tag)
    obj.save
    
    render :layout => 'content'
  end

  def remove
#    @tag = Tag.find(params[:id])
#    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end
end
