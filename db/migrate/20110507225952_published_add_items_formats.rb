#
# Forgot about this in the create...
#
class PublishedAddItemsFormats < ActiveRecord::Migration
  def self.up
     remove_column :published_programme_items, :format
     add_column :published_programme_items, :format_id, :integer
  end

  def self.down
    add_column :published_programme_items, :format, :string
    remove_column :published_programme_items, :format_id
  end
end
