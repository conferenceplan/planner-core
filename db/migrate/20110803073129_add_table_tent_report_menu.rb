class AddTableTentReportMenu < ActiveRecord::Migration
   def self.up
     MenuItem.create(:name => "Create CSV for Table Tents", :path => "/planner_reports/tableTents", :menu_item => MenuItem.find_by_name("Planner Reports"))
  end

  def self.down
      MenuItem.find_by_name("Create CSV for Table Tents").destroy
  end
end
