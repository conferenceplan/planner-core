class AddLibraryTalkReportToMenu < ActiveRecord::Migration
  def self.up
    menu = MenuItem.find_by_name("Reports")
    MenuItem.create(:name => "Library Talks", :path => "/survey_reports/library_talks/", :menu_item => menu)
    MenuItem.create(:name => "Missing Bio", :path => "/survey_reports/missing_bio/", :menu_item => menu)
  end

  def self.down
    item = MenuItem.find_by_name("Library Talks")
    item.destroy
    item = MenuItem.find_by_name("Missing Bio")
    item.destroy
  end
end
