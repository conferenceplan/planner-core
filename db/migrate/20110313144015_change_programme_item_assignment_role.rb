class ChangeProgrammeItemAssignmentRole < ActiveRecord::Migration
  def self.up
     remove_column :programme_item_assignments, :role
     add_column :programme_item_assignments, :role_id, :integer
  end

  def self.down
  end
end
