class AddUpdateSelect < ActiveRecord::Migration
  def self.up
    menu = MenuItem.find_by_name("Planner Reports")
    MenuItem.create(:name => "Update Report (Pink Sheet)", :path => "/program/updateSelect", :menu_item => menu)
  end

  def self.down
    item = MenuItem.find_by_name("Generate Update Report (Pink Sheet)").destroy
  end
end
