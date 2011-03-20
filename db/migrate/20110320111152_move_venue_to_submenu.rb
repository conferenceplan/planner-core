class MoveVenueToSubmenu < ActiveRecord::Migration
  def self.up
     execute "update menu_items set menu_id = NULL, menu_item_id = 41 where id = 47;"
  end

  def self.down
     execute "update menu_items set menu_id = 4, menu_item_id = NULL where id = 47;"
  end
end
