class AddRoomSignReportToMenu < ActiveRecord::Migration
  def self.up
     MenuItem.create(:name => "Create CSV for Room Signs", :path => "/planner_reports/selectRoomSign", :menu_item => MenuItem.find_by_name("Planner Reports"))
  end

  def self.down
      MenuItem.find_by_name("Create CSV for Room Signs").destroy
  end
end
