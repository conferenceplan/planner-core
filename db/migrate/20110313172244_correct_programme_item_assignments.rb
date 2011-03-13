class CorrectProgrammeItemAssignments < ActiveRecord::Migration
  def self.up
    remove_column :programme_item_assignments, :event_id
    add_column :programme_item_assignments, :programme_item_id, :integer
  end

  def self.down
  end
end
