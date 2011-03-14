class RoomsController < PlannerController
  def index
    logger.debug ">>>>>>>>In index"
  end

  def list
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]

    clause = createWhereClause(params[:filters])

    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB
    count = Room.count :conditions => clause
    @nbr_pages = (count / rows.to_i).floor + 1
    
    off = (@page.to_i - 1) * rows.to_i
    @rooms = Room.find :all, :offset => off, :limit => rows, :order => idx + " " + order, :conditions => clause
   
    respond_to do |format|
      format.xml
    end
  end

  def show
    @room = Room.find(params[:id])
    @venue = Venue.find @room.venue_id
  end
  def create
      logger.debug ">>>>>>>>In create"
    @room = Room.new(params[:room])
    if (@room.save)
       render :action => 'index', :layout => 'content'
    else
      render :content
    end 
  end
  def new
    @room = Room.new
    @venues = Venue.find :all
  end
  
  #def edit
    #@room = Room.find(params[:id])
    #@venues = Venue.find :all
  #end
  
  def update
    @room = Room.find(params[:id])
    if @room.update_attributes(params[:room])
      render :action => 'index', :layout => 'content'
    else
      render :action => 'edit', :layout => 'content'
    end
  end
  
  def destroy
    @room = Room.find(params[:id])
    @room.destroy
    #redirect_to :action => 'index'
    render :layout => 'success'
  end
  
end
