class AddDescriptionToProgrammeItemTables < ActiveRecord::Migration
  def change
    add_column :programme_items, :description, :text
    add_column :programme_items, :short_description, :text
    add_column :published_programme_items, :description, :text
  end
end
