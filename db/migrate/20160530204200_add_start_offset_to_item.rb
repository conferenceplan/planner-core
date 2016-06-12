class AddStartOffsetToItem < ActiveRecord::Migration
  def change
    add_column :programme_items, :start_offset, :integer, {:default => 0}
    add_column :published_programme_items, :start_offset, :integer, {:default => 0}
  end
end
