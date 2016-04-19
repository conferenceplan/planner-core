class AddSortOrderToAssignment < ActiveRecord::Migration
  def change
    add_column :programme_item_assignments, :sort_order, :integer, {:default => 0}
    add_column :published_programme_item_assignments, :sort_order, :integer, {:default => 0}
  end
end
