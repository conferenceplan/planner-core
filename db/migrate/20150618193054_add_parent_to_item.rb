class AddParentToItem < ActiveRecord::Migration
  def change
    add_column :programme_items, :is_parent, :boolean, {:default => false}
  end
end
