class AddProgTypeReportToMenu < ActiveRecord::Migration
  def self.up
    menu = MenuItem.find_by_name('Reports')
    MenuItem.create(:name => 'Search by Program Type', :path => "/survey_reports/program_types/", :menu_item => menu)
  end

  def self.down
    MenuItem.find_by_name('Search by Program Type').destroy
  end
end
