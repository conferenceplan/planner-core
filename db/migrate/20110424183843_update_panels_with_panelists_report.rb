class UpdatePanelsWithPanelistsReport < ActiveRecord::Migration
  def self.up
     item = MenuItem.find_by_name("Panels with Panelists")
     item.path = '/planner_reports/panels_with_panelists'
     item.save
  end

  def self.down
     item = MenuItem.find_by_name("Panels with Panelists")
     item.path = '/planner_reports/panels_date_form'
     item.save
  end
end
