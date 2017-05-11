class AddVisibilityIdToItems < ActiveRecord::Migration
  def change
    add_column :programme_items, :visibility_id, :integer
    add_column :published_programme_items, :visibility_id, :integer
  end
end
