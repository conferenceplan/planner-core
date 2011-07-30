class AddPanelsByTimeslot < ActiveRecord::Migration
  def self.up
    menu = MenuItem.find_by_name("Planner Reports")
    MenuItem.create(:name => "Panels by Timeslot (ProgOps)", :path => "/planner_reports/panels_by_timeslot/", :menu_item => menu)
  end

  def self.down
    item = MenuItem.find_by_name("Panels by Timeslot (ProgOps)").destroy
  end
end
