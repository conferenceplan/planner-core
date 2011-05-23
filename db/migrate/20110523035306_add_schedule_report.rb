class AddScheduleReport < ActiveRecord::Migration
  def self.up
     MenuItem.create(:name => "Export for Schedule Mailing", :path => "/planner_reports/schedule_report", :menu_item => MenuItem.find_by_name("Planner Reports"))
  end

  def self.down
     MenuItem.find_by_name("Export for Schedule Mailing").destroy
  end
end
