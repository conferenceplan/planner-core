class VenueController < PlannerController
   def index
      @venues = Venue.find :all
      @rooms = Array.new
      @venues.each do |v|
         @rooms[v.id] = Room.count :conditions => {:venue_id => v.id}
      end
   end
   def show
      @venue = Venue.find params[:id]
      @rooms = Room.find :all, :conditions => {:venue_id => params[:id]}
   end
   def new
      @venue = Venue.new
   end
   def create
      @venue = Venue.new params[:venue]
      if @venue.save
         redirect_to :action => 'index'
      else
         render :action => 'new'
      end
   end
   def edit
      @venue = Venue.find params[:id]
   end
   def update
      @venue = Venue.find params[:id]
      if @venue.update_attributes params[:venue]
         redirect_to :action => 'index'
      else
         render :action => 'edit'
      end
   end
   def destroy
      Venue.find(params[:id]).destroy
      redirect_to :action => 'index'
   end
end
