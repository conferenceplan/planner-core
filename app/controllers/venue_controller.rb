#
#
#
class VenueController < PlannerController
  
  #
  #
  #
  def list
    @venues = Venue.find :all
  end

  #
  #
  #
  def show
    @venue = Venue.find params[:id]
  end
  
  #
  #
  # 
  def create
    @venue = Venue.new params[:venue]
    @venue.save!
  end

  #
  #
  #    
  def update
    @venue = Venue.find params[:id]
    @venue.update_attributes params[:venue]
  end

  #
  #
  #   
  def destroy
    venue = Venue.find(params[:id])
     
    # make sure that there are no rooms
    if venue.rooms.length == 0
      venue.destroy
      render status: :ok, text: {}.to_json
    else
      render status: :bad_request, text: 'Con not delete venue that has rooms'
    end
  end
   
end
