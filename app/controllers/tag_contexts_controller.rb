class TagContextsController < PlannerController
  # GET /tag_contexts
  # GET /tag_contexts.xml
  def index
    @tag_contexts = TagContext.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @tag_contexts }
    end
  end

  # GET /tag_contexts/1
  # GET /tag_contexts/1.xml
  def show
    @tag_context = TagContext.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @tag_context }
    end
  end

  # GET /tag_contexts/new
  # GET /tag_contexts/new.xml
  def new
    @tag_context = TagContext.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag_context }
    end
  end

  # GET /tag_contexts/1/edit
  def edit
    @tag_context = TagContext.find(params[:id])
  end

  # POST /tag_contexts
  # POST /tag_contexts.xml
  def create
    @tag_context = TagContext.new(params[:tag_context])

    respond_to do |format|
      if @tag_context.save
        format.html { redirect_to(@tag_context, :notice => 'TagContext was successfully created.') }
        format.xml  { render :xml => @tag_context, :status => :created, :location => @tag_context }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag_context.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tag_contexts/1
  # PUT /tag_contexts/1.xml
  def update
    @tag_context = TagContext.find(params[:id])

    respond_to do |format|
      if @tag_context.update_attributes(params[:tag_context])
        format.html { redirect_to(@tag_context, :notice => 'TagContext was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag_context.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tag_contexts/1
  # DELETE /tag_contexts/1.xml
  def destroy
    @tag_context = TagContext.find(params[:id])
    @tag_context.destroy

    respond_to do |format|
      format.html { redirect_to(tag_contexts_url) }
      format.xml  { head :ok }
    end
  end
end
