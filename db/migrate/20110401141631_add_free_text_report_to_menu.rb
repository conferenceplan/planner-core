class AddFreeTextReportToMenu < ActiveRecord::Migration
  def self.up
    menu = MenuItem.find_by_name('Reports')
    MenuItem.create(:name => 'Search Free Text Questions', :path => "/survey_reports/free_text/", :menu_item => menu)
  end

  def self.down
    MenuItem.find_by_name('Search Free Text Questions').destroy
  end
end
