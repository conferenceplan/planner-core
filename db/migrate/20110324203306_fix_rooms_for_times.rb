class FixRoomsForTimes < ActiveRecord::Migration
  def self.up
      remove_column :rooms, :survey_id
  end

  def self.down
  end
end


# TODO - we need to figure out the rooms => time_slots
# ALso rooms are part of the Venue
# Schedule should have a start and end date and be for a specific convention or type of actvitity
# Rooms need a start and end time for when they are available for programme - RL suggested a time_slot master
# Which would mean room <=> time_slot <=> item
# item => room (room has many items)
# item => time_slot (item has one time slot)
# room => time_slot (room has many time slot - available times)
# Need to get items associated with a room sorted by their time slot
#