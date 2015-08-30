class AddParentChildToPublishedItems < ActiveRecord::Migration
  def change
    add_column :published_programme_items, :parent_id, :integer, {:index => true}
  end
end
