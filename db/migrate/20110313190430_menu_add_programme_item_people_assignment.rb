class MenuAddProgrammeItemPeopleAssignment < ActiveRecord::Migration
  def self.up
    menu = MenuItem.all(:conditions => { :name => "Items" } ).first
    MenuItem.create( :name => "Add People", :path => "/item_planner", :menu_item => menu)
  end

  def self.down
  end
end
