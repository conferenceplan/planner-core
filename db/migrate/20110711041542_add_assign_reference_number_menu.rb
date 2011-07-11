class AddAssignReferenceNumberMenu < ActiveRecord::Migration
  def self.up
    menu = MenuItem.all(:conditions => { :name => "Items" } ).first
    MenuItem.create( :name => "Assign Item Reference Numbers", :path => "/programme_items/assign_reference_numbers", :menu_item => menu)
  end

  def self.down
  end
end
