class AddPanelistsWithPanelsReport < ActiveRecord::Migration
  def self.up
    item = MenuItem.find_by_name("Planner Reports")
    MenuItem.create(:name => 'Panelists with Panels', :path => "/planner_reports/panelists_with_panels/", :menu_item => item)
  end

  def self.down
    MenuItem.find_by_name('Panelists with Panels').destroy
  end
end
