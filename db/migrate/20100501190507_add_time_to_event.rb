class AddTimeToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :time_slot_id, :integer
  end

  def self.down
    remove_column :events, :time_slot_id
  end
end
