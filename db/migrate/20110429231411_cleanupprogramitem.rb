class Cleanupprogramitem < ActiveRecord::Migration
  def self.up
     # These columns are not used in the programme item table (reference is done through an intermediary table)
     remove_column :programme_items, :time_slot_id
     remove_column :programme_items, :room_id
 end

  def self.down
  end
end
