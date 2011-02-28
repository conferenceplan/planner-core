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

  # GET /tags/new
  # GET /tags/new.xml
  def new
    @tag = Tag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/1/edit
  def edit
    @tag = Tag.find(params[:id])
  end

  # POST /tags
  # POST /tags.xml
  def create
    @tag = Tag.new(params[:tag])

    respond_to do |format|
      if @tag.save
        format.html { redirect_to(@tag, :notice => 'Tag was successfully created.') }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tags/1
  # PUT /tags/1.xml
  def update
    @tag = Tag.find(params[:id])

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        format.html { redirect_to(@tag, :notice => 'Tag was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end
end
