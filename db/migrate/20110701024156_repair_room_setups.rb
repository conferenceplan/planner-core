require 'room'
require 'room_setup'

class RepairRoomSetups < ActiveRecord::Migration
  def self.up
    add_column :rooms, :setup_id, :integer    #  Default
    Room.reset_column_information

    Room.all.each do |room|
      roomSetup = RoomSetup.find_by_room_id room.id
      room.setup_id = roomSetup.id
      room.save
    end
    
    remove_column :rooms, :setup_type_id

  end

  def self.down
  end
end
