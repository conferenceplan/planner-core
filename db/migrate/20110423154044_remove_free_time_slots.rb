class RemoveFreeTimeSlots < ActiveRecord::Migration
  def self.up
    RoomItemAssignment.transaction do
      candidates = RoomItemAssignment.all(:conditions => "programme_item_id is null")
      # delete all the assignments that do not have a programme item associated with it
      candidates.each do |candidate|
        candidate.delete
        candidate.time_slot.delete
      end
    end
  end
  
  def self.down
  end
end
