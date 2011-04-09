class UpdateReportMenus < ActiveRecord::Migration
  def self.up
    item = MenuItem.find_by_name("Reports")
    item.name = "Survey Reports"
    item.save

    menu = Menu.find_by_title("Main")
    item = MenuItem.create(:name => "Planner Reports", :path => "/planner_reports", :menu => menu)
    MenuItem.create(:name => "Panels with Panelists", :path => "/planner_reports/panels_date_form", :menu_item => item)
    
  end

  def self.down
     MenuItem.find_by_name("Panels with Panelists").destroy
     MenuItem.find_by_name("Planner Reports").destroy
     item = MenuItem.find_by_name("Survey Reports")
     item.name = "Reports"
     item.save
  end
end
