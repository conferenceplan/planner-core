class AddUpdateConfItemMenu < ActiveRecord::Migration
  def self.up
     partMenu = MenuItem.all(:conditions => { :name => "Participants" } ).first
     MenuItem.create( :name => "Update Conflicts Items from Surveys", :path => "/participants/updateConflictsItemsFromSurvey", :menu_item => partMenu)
  end

  def self.down
     MenuItem.find_by_name("Update Conflicts Items from Surveys").destroy
  end
end
