class AddEquipmentMenus < ActiveRecord::Migration
  def self.up
    menu = Menu.find_by_title("Main")
    eq_menu = MenuItem.create(:name => "Equipment", :menu => menu)
    MenuItem.create(:name => "Equipment Types", :path => "/equipment_types", :menu_item => eq_menu)
  end

  def self.down
    MenuItem.find_by_name("Equipment Types").destroy
    MenuItem.find_by_name("Equipment").destroy
  end
end
