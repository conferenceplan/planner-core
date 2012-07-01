class AddSurveyManagementToMenu < ActiveRecord::Migration
  def self.up
     MenuItem.create(:name => "Manage Surveys", :path => "/surveys", :menu_item => MenuItem.find_by_name("Admin"))
  end

  def self.down
      MenuItem.find_by_name("Manage Surveys").destroy
  end
end
