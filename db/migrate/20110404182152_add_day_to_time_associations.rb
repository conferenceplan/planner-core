class AddDayToTimeAssociations < ActiveRecord::Migration
  def self.up
     rename_table :room_item_assigments, :room_item_assignments
     add_column :room_item_assignments, :day, :integer, { :default => -1 }
  end

  def self.down
     remove_column :room_item_assignments, :day
     rename_table :room_item_assignments, :room_item_assigments
  end
end

