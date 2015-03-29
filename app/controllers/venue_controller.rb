#
#
#
class VenueController < PlannerController

  #
  #
  #
  def update_row_order
    begin
      Venue.transaction do

        venue = Venue.find(params[:venue_id])
        venue.sort_order_position = params[:venue_order_position]
        venue.save
    
        render status: :ok, text: {}.to_json
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end
    
  #
  #
  #
  def index
    limit = params[:limit] ? params[:limit].to_i : nil
    offset = params[:offset] ? params[:offset].to_i : nil
    
    @total = Venue.count
    
    @venues = Venue.offset(offset).limit(limit)
  end
  
  #
  #
  #
  def list
    limit = params[:limit] ? params[:limit].to_i : nil
    offset = params[:offset] ? params[:offset].to_i : nil
    
    @total = Venue.count
    
    if limit > 0
      @venues = Venue.scoped.offset(offset).limit(limit)
    else  
      @venues = Venue.all
    end


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

    if params[:postal_address]
      pa = PostalAddress.new( params[:postal_address] )
      pa.save!
      addr = @venue.build_address({
        venue_id: @venue.id,
        addressable: pa
      })
      addr.save!
    end
  end

  #
  #
  #    
  def update
    @venue = Venue.find params[:id]
    @venue.update_attributes params[:venue]
    
    if params[:postal_address]
      if !@venue.postal_address
        pa = PostalAddress.new( params[:postal_address] )
        pa.save!
        addr = @venue.build_address({
          venue_id: @venue.id,
          addressable: pa
        })
        addr.save!
      else
        @venue.postal_address.update_attributes params[:postal_address]
      end
      @venue.save!
    end
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
      render status: :bad_request, text: 'Can not delete venue that has rooms'
    end
  end
   
end
