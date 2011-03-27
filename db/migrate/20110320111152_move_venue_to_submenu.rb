class MoveVenueToSubmenu < ActiveRecord::Migration
  def self.up
    menu = MenuItem.find_by_name( "Rooms" )
    item = MenuItem.find_by_name( "Venues" )
    item.menu_item_id = menu.id
    item.menu_id = nil
    item.save
  end

  def self.down
    menu = Menu.find_by_title( "Main" )
    item = MenuItem.find_by_name( "Venues" )
    item.menu_id = menu.id
    item.save
  end
end
