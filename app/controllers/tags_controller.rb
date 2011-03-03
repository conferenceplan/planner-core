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
    @className = params[:class]
    obj = eval(@className).find(params[:id])
    
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
    context = params[:context] # context
    className = params[:class] # class
    
    if isok(className)
      obj = eval(className).find(params[:id]) # object find by id
      tagList = params[:tag].split(',') # allow the addition of multiple tags (comma seperated)
    
      tagList.each do |tag|
        obj.tag_list_on(context).add(tag)
      end
      obj.save
    end
    
    render :layout => 'content'
  end

  def remove
    context = params[:context] # context
    className = params[:class] # class

    if isok(className)
      obj = eval(className).find(params[:id]) # object find by id
      tag = params[:tag]

      obj.tag_list_on(context).delete(tag)
      obj.save
    end

    render :layout => 'content'
  end

# Create the edit form , the result will be to add a new tag(s)
# http://localhost:3000/tags/1/edit?class=Person&context=scienceItems
  def edit
    @context = params[:context] # context
    @className = params[:class] if isok(params[:class])
    @id = params[:id]

    # Just pass on to the form that will allow us to 'edit' the tag list i.e. to add tags
    respond_to do |format|
      format.html {render :layout => 'content'} # new.html.erb
    end
  end

  private
  
  #
  # Make sure that the parameter is not trying to execute a system command
  #
  def isok(input)
    # make sure that the input does not contain system ''
    ! input.downcase.include? 'system'
  end
  
end
