class AddPanelistMetadataReport < ActiveRecord::Migration
  def self.up
    menu = MenuItem.find_by_name('Survey Reports')
    MenuItem.create(:name => 'Panelists with Details', :path => "/survey_reports/panelists_with_metadata/", :menu_item => menu)
  end

  def self.down
    MenuItem.find_by_name('Panelists with Details').destroy
  end
end
