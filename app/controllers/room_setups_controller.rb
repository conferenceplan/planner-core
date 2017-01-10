#
#
#
class RoomSetupsController < PlannerController

  #
  #
  #
  def list
    room_id = params[:room_id]
    @room_setups = RoomSetup.where({:room_id => room_id}).includes(:setup_type)
  end

  #
  #
  #
  def show
    @room_setup = RoomSetup.find(params[:id])
  end

  #
  #
  #
  def create
    setupData = params[:room_setup].merge({:room_id => params[:room_id]})
    defaultSetup = params[:isdefault]
    
    begin
      RoomSetup.transaction do
        
        if params[:setup_type_name]
          setup_type = SetupType.where(name: params[:setup_type_name]).first_or_create
          setupData = setupData.merge({:setup_type_id => setup_type.id})
        end

        if setupData[:setup_type_id]
          @room_setup = RoomSetup.new(setupData)
          if (@room_setup.save!)
            setRoomDefault @room_setup if defaultSetup
            unSetRoomDefault @room_setup if !defaultSetup
          end
        end

      end
    rescue ActiveRecord::RecordInvalid => e  
      render status: :bad_request, text: 'Unable to create room setup, probably a duplicate setup type'
    rescue => ex
      render status: :bad_request, text: ex.message
    end
  end

  #
  #
  #
  def update
    setupData = params[:room_setup]
    defaultSetup = params[:isdefault]
    
    begin
      RoomSetup.transaction do

        if params[:setup_type_name]
          setup_type = SetupType.where(name: params[:setup_type_name]).first_or_create
          setupData = setupData.merge({:setup_type_id => setup_type.id})
        end

        if setupData[:setup_type_id]
          @room_setup = RoomSetup.find(params[:id])
          if @room_setup.update_attributes(setupData)
            setRoomDefault @room_setup if defaultSetup
            unSetRoomDefault @room_setup if !defaultSetup
          end
        end
      
      end
    # rescue => ex
      # render status: :bad_request, text: ex.message
    end
  end

  #
  #
  #
  def destroy
    room_setup = RoomSetup.find(params[:id])
    room = Room.find_by_setup_id(room_setup.id)
    if room.nil? # if it is not the default
      room_setup.destroy
      render status: :ok, text: {}.to_json
    else
      render status: :bad_request, text: 'Unable to delete setup as it is in use'
    end
  end
  
  #
  #
  #
  def setRoomDefault(_room_setup)
    room = Room.find(_room_setup.room_id)
    room.room_setup = _room_setup
    room.save!
  end
  
  def unSetRoomDefault(_room_setup)
    room = _room_setup.room
    if room.room_setup && (room.room_setup.id == _room_setup.id)
      room.room_setup = nil
      room.save!
    end
  end

end
