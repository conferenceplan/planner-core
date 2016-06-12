class AddRoleNameToAssignments < ActiveRecord::Migration
  def change
    add_column :programme_item_assignments, :description, :string, {:default => nil}
    add_column :published_programme_item_assignments, :description, :string, {:default => nil}
  end
end
