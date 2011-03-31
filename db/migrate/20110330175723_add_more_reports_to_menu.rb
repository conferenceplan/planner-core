class AddMoreReportsToMenu < ActiveRecord::Migration
  def self.up
     menu = MenuItem.find_by_name("Reports")
     MenuItem.create(:name => 'Moderators', :path => "/survey_reports/moderators/", :menu_item => menu)
     MenuItem.create(:name => 'Art Night', :path => "/survey_reports/art_night/", :menu_item => menu)
     MenuItem.create(:name => 'Music Night', :path => "/survey_reports/music_night/", :menu_item => menu)
  end

  def self.down
    MenuItem.find_by_name("Moderators").destroy
    MenuItem.find_by_name("Art Night").destroy
    MenuItem.find_by_name("Music Night").destroy
  end
end
