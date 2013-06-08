class Updateconflictmenu < ActiveRecord::Migration
  def self.up
     partMenu = MenuItem.all(:conditions => { :name => "Participants" } ).first
     MenuItem.create( :name => "Update Conflicts from Surveys", :path => "/participants/updateConflictsFromSurvey", :menu_item => partMenu)
     MenuItem.find_by_name("Update Conflict Times from Surveys").destroy
     MenuItem.find_by_name("Update Conflict Items from Surveys").destroy

  end

  def self.down
     partMenu = MenuItem.all(:conditions => { :name => "Participants" } ).first
     MenuItem.create( :name => "Update Conflict Items from Surveys", :path => "/participants/updateExcludedItemsFromSurveys", :menu_item => partMenu)
     MenuItem.create( :name => "Update Conflict Times from Surveys", :path => "/participants/updateExcludedTimesFromSurveys", :menu_item => partMenu)
     MenuItem.find_by_name("Update Conflicts from Surveys").destroy
  end
end
