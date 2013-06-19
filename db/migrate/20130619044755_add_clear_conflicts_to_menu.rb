class AddClearConflictsToMenu < ActiveRecord::Migration
  def self.up
     partMenu = MenuItem.all(:conditions => { :name => "Participants" } ).first
     MenuItem.create( :name => "Clear Conflicts from Surveys", :path => "/participants/clearConflictsFromSurvey", :menu_item => partMenu)

  end

  def self.down
     MenuItem.find_by_name("Clear Conflicts from Surveys").destroy
  end
end
