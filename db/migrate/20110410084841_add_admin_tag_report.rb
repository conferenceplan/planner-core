class AddAdminTagReport < ActiveRecord::Migration
  def self.up
     MenuItem.create(:name => "Admin Tags by Context", :path => "/planner_reports/admin_tags_by_context", :menu_item => MenuItem.find_by_name("Planner Reports"))
  end

  def self.down
     MenuItem.find_by_name("Admin Tags by Context").destroy
  end
end
