class AddBreakFlag < ActiveRecord::Migration
  def change
    add_column :programme_items, :is_break, :boolean, {:default => false}
    add_column :published_programme_items, :is_break, :boolean, {:default => false}
  end
end
