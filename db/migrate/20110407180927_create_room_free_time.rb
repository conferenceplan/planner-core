class CreateRoomFreeTime < ActiveRecord::Migration
  def self.up
    rooms = Room.find_by_sql("SELECT * FROM rooms where rooms.id not in (SELECT room_id FROM room_free_times)")
    
    rooms.each do |room|
      SITE_CONFIG[:conference][:number_of_days].times { |d|
        ts = TimeSlot.new(:start => Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + d.day,
              :end => Time.zone.parse(SITE_CONFIG[:conference][:start_date]) + d.day + 23.hours + 59.minutes)
        ts.save
        ft = RoomItemAssignment.new(:room_id => room.id, :time_slot_id => ts.id, :day => d)
        ft.save
      }
    end
  end

  def self.down
  end
end
