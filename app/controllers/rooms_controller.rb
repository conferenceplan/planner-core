#
#
#
class RoomsController < ResourceController

  #
  #
  #
  def update_row_order
    begin
      Room.transaction do

        room = Room.find(params[:room_id])
        room.sort_order_position = params[:room_order_position]
        room.save

        render status: :ok, text: {}.to_json
      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end


  def purposes
    query = params[:query] ? params[:query] : ""
    
    res = Room.unscoped.where("purpose like ?", "%" + query + "%").select("distinct purpose")
    
    render json: res.collect{|r| r.purpose}.to_json, :content_type => 'application/json'
  rescue => ex
    render status: :bad_request, text: ex.message
  end

  #
  #
  #
  def index
    @rooms = Room.unscoped.includes(:venue).order('venues.sort_order asc, rooms.sort_order asc')
  end

  #
  #
  #
  def simple_list
    limit = params[:limit] ? params[:limit].to_i : nil
    offset = params[:offset] ? params[:offset].to_i : nil
    venue = params[:venue] ? params[:venue].to_i : nil

    @total = Room.where({venue_id: venue}).count

    if limit > 0
      @rooms = Room.where({venue_id: venue}).offset(offset).limit(limit)
    else
      @rooms = Room.where({venue_id: venue})
    end
  end

  #
  #
  #
  def list
    rows = params[:rows] ? params[:rows] : 15
    @page = params[:page] ? params[:page].to_i : 1
    idx   = params[:sidx]
    order = params[:sord]
    filters = params[:filters]
    page_to = params[:page_to]
    @currentId = params[:current_selection]
    venue_id = params[:venue_id]

    @count = RoomsService.countRooms filters, venue_id

    if page_to && !page_to.empty?
      gotoNum = RoomsService.countRooms filters, venue_id, page_to
      if gotoNum
        @page = (gotoNum / rows.to_i).floor
        @page += 1 if gotoNum % rows.to_i > 0
      end
    end

    if rows.to_i > 0
      @nbr_pages = (@count / rows.to_i).floor
      @nbr_pages += 1 if @count % rows.to_i > 0
    else
      @nbr_pages = 1
    end

    @rooms = RoomsService.findRooms rows, @page, idx, order, filters, venue_id
  end

  #
  #
  #
  def show
    @room = Room.find(params[:id])
  end

  #
  #
  #
  def create
    roomData = params[:room].merge({:venue_id => params[:venue_id]})

    begin
      Room.transaction do

        @room = Room.new(roomData)
        @room.save!

        # TODO - set a default setup type???
        # type = SetupType.find_by(name: SetupType::THEATRE)
        # roomSetup = RoomSetup.new(:room_id => @room.id, :setup_type_id => type.id)
        # roomSetup.save
        # @room.setup_id = roomSetup.id

      end
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

  #
  #
  #
  # def update

  #   begin
  #     Room.transaction do

  #       @room = Room.find(params[:id])
  #       @room.update_attributes(params[:room])

  #     end
  #   rescue => ex
  #     render status: :bad_request, text: ex.message
  #   end

  # end

  #
  #
  #
  def destroy
    room = Room.find(params[:id])
    # Delete the time associations with this room as well
    room.removeAllTimes
    room.destroy

    render status: :ok, text: {}.to_json
  end


  def for_select2
    query = nil
    # Will not work since rooms do not have names, translations needed
    # if params[:search].present?
    #   query = "rooms.name like '%" + params[:search].strip + "%'"
    # end

    @grouped_rooms = Room.joins(:venue).where(query).reorder('venues.sort_order asc, rooms.sort_order asc').group_by(&:venue)
  end

end
