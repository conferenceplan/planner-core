class AddProgBookReport < ActiveRecord::Migration
  def self.up
     MenuItem.create(:name => "Export for Prog Guide", :path => "/planner_reports/program_book_report", :menu_item => MenuItem.find_by_name("Planner Reports"))
  end

  def self.down
     MenuItem.find_by_name("Export for Prog Guide").destroy
  end
end
