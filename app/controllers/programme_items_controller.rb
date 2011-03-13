class ProgrammeItemsController < PlannerController
  
  def index
    @programmeItems = ProgrammeItem.find :all
  end
  def show
    @programmeItem = ProgrammeItem.find(params[:id])
    render :layout => 'content'
  end
  def create
# NOTE - name of the programmeItem passed in from form
    @programmeItem = ProgrammeItem.new(params[:programme_item])
    if (@programmeItem.save)
       redirect_to :action => 'index', :id => @programmeItem
    else
      render :action => 'new'
    end 
  end
  def new
    @programmeItem = ProgrammeItem.new
    @programmeItem.duration = 60
    @programmeItem.minimum_people = 3
    @programmeItem.maximum_people = 5
    @programmeItem.print = true
  end
  
  def edit
    @programmeItem = ProgrammeItem.find(params[:id])
    render :layout => 'content'
  end
  
  def update
    @programmeItem = ProgrammeItem.find(params[:id])
    if @programmeItem.update_attributes(params[:programme_item])
      redirect_to :action => 'show', :id => @programmeItem
    else
      render :action => 'edit', :layout => 'content'
    end
  end
  
  def destroy
    @programmeItem = ProgrammeItem.find(params[:id])
    @programmeItem.destroy
    redirect_to :action => 'index'
  end
  #
  
  def list
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]
    nameSearch = params[:namesearch]
    
    clause = createWhereClause(params[:filters], 
                  ['format_id'],
                  ['format_id'])

    # add the name search of the title
    if nameSearch && ! nameSearch.empty?
      clause = addClause(clause,'title like ?','%' + nameSearch + '%')
    end

    args = { :conditions => clause }
  
    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB
    args.merge!(:include => :format)
    @count = ProgrammeItem.count args

    @nbr_pages = (@count / rows.to_i).floor
    @nbr_pages += 1 if @count % rows.to_i > 0
    
    offset = (@page.to_i - 1) * rows.to_i
    args.merge!(:offset => offset, :limit => rows, :order => idx + " " + order)
    
    @programmeItems = ProgrammeItem.find :all, args

    # We return the list of ProgrammeItems as an XML structure which the 'table' can use.
    respond_to do |format|
      format.html { render :layout => 'content' } # list.html.erb
      format.xml
    end
  end

end
