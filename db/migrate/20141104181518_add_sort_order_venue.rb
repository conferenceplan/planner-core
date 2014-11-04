class AddSortOrderVenue < ActiveRecord::Migration
  def change
    add_column :venues, :sort_order, :integer, { :default => 0 }
    add_column :rooms, :sort_order, :integer, { :default => 0 }
    add_column :published_venues, :sort_order, :integer, { :default => 0 }
    add_column :published_rooms, :sort_order, :integer, { :default => 0 }
  end
end
