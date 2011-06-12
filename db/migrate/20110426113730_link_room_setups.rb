class LinkRoomSetups < ActiveRecord::Migration
  
  def self.up
    theatre = SetupType.create(:name => SetupType::THEATRE, :description => "Theatre seating")
    
    Room.all.each do |room|
      RoomSetup.create :room_id => room.id, :setup_type_id => theatre.id, :capacity => room.capacity
    end
    
    remove_column :rooms, :capacity
    add_column :programme_items, :setup_type_id, :integer
    add_column :rooms, :setup_type_id, :integer    #  Default
    
    ProgrammeItem.reset_column_information
    Room.reset_column_information
    
    Room.update_all :setup_type_id => theatre.id
    ProgrammeItem.update_all :setup_type_id => theatre.id
  end

  def self.down
    remove_column :rooms, :setup_type_id
    remove_column :programme_items, :setup_type_id
    
    add_column :rooms, :capacity, :integer
    Room.reset_column_information

    theatre = SetupType.find_by_name(SetupType::THEATRE)
    
    RoomSetup.find_all_by_setup_type_id(theatre.id).each do |rs|
      r = Room.find(rs.room_id)
      r.capacity = rs.capacity
      r.save
    end
    
    theatre.destroy
  end
end
