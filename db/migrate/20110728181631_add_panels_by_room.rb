class AddPanelsByRoom < ActiveRecord::Migration
  def self.up
    menu = MenuItem.find_by_name("Planner Reports")
    MenuItem.create(:name => "Panels by Room (ProgOps)", :path => "/planner_reports/panels_by_room/", :menu_item => menu)
  end

  def self.down
    item = MenuItem.find_by_name("Panels by Room (ProgOps)").destroy
  end
end
