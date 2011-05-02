class AddUpdateSurveyItemConflictsMenu < ActiveRecord::Migration
  def self.up
     partMenu = MenuItem.all(:conditions => { :name => "Participants" } ).first
     MenuItem.create( :name => "Update Conflict Items from Surveys", :path => "/participants/updateExcludedItemsFromSurveys", :menu_item => partMenu)
  end

  def self.down
  end
end
