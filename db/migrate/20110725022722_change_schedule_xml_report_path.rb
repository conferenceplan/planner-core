class ChangeScheduleXmlReportPath < ActiveRecord::Migration
  def self.up
     item = MenuItem.find_by_name("Export for Schedule Mailing")
     item.path = '/planner_reports/selectScheduleReport'
     item.save
  end

  def self.down
     item = MenuItem.find_by_name("Export for Schedule Mailing")
     item.path = '/planner_reports/schedule_report'
     item.save
  end
end
