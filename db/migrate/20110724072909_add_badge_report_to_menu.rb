class AddBadgeReportToMenu < ActiveRecord::Migration
  def self.up
     MenuItem.create(:name => "Create CSV for back of badge label", :path => "/planner_reports/selectBadgeLabel", :menu_item => MenuItem.find_by_name("Planner Reports"))
  end

  def self.down
      MenuItem.find_by_name("Create CSV for back of badge label").destroy
  end
end
