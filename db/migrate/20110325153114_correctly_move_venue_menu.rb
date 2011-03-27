class CorrectlyMoveVenueMenu < ActiveRecord::Migration
  def self.up
    roomMenu = MenuItem.all(:conditions => { :name => "Rooms" } ).first
    menu = MenuItem.all(:conditions => { :name => "Venues" } ).first
    menu.menu = nil
    menu.menu_item = roomMenu
    menu.save
  end

  def self.down
    rootMenu = Menu.find_by_title("Main")
    menu = MenuItem.all(:conditions => { :name => "Venues" } ).first
    menu.menu = rootMenu
    menu.menu_item = nil
    menu.save
  end
end
