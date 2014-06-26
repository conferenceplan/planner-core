class AddShortPrecis < ActiveRecord::Migration
  def change
    add_column :programme_items, :short_precis, :text
  end
end
