class AddParentChildToItems < ActiveRecord::Migration
  def change
    add_column :programme_items, :parent_id, :integer, {:index => true}
  end
end
