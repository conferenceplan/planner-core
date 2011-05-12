class AddUpdateTimeToMenu < ActiveRecord::Migration
  def self.up
     partMenu = MenuItem.all(:conditions => { :name => "Participants" } ).first
     MenuItem.create( :name => "Update Conflict Times from Surveys", :path => "/participants/updateExcludedTimesFromSurveys", :menu_item => partMenu)
  
  end

  def self.down
  end
end
