class RoomsController < PlannerController
  def index
  end

  #
  def list
    rows = params[:rows]
    @page = params[:page]
    idx = params[:sidx]
    order = params[:sord]

    clause = createWhereClause(params[:filters])

    args = { :conditions => clause }
    # First we need to know how many records there are in the database
    # Then we get the actual data we want from the DB
    @count = Room.count args
    if rows.to_i > 0
      @nbr_pages = (@count / rows.to_i).floor + 1
    
      off = (@page.to_i - 1) * rows.to_i
      args.merge!(:offset => off, :limit => rows, :order => idx + " " + order)
    end

    @rooms = Room.find :all, args
   
    respond_to do |format|
      format.html { render :layout => 'plain' } # list.html.erb
      format.xml
    end
  end

  def show
    @room = Room.find(params[:id])
    @venue = Venue.find @room.venue_id
  end
  def create
    @room = Room.new(params[:room])
    if (@room.save)
       initialiseFreeTime(@room)
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
    
    # Delete the time associations with this room as well
    @room.removeAllTimes
    
    @room.destroy
    #redirect_to :action => 'index'
    render :layout => 'success'
    
  end
  
private

  def initialiseFreeTime(room)
      SITE_CONFIG[:conference][:number_of_days].times { |d|
        ts = TimeSlot.new(:start => Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + d.day,
              :end => Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + d.day + 23.hours + 59.minutes)
        ts.save
        ft = RoomItemAssignment.new(:room => room, :time_slot => ts, :day => d)
        ft.save
      }
  end

end
