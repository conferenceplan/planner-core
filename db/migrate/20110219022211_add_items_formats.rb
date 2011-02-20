class AddItemsFormats < ActiveRecord::Migration
 def self.up
     remove_column :programme_items, :format
     add_column :programme_items, :format_id, :integer
  end

  def self.down
    add_column :programme_items, :format, :string
    remove_column :programme_items, :format_id
  end
end
