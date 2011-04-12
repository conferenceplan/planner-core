class AddAvailabilityDuringReport < ActiveRecord::Migration
  def self.up
    menu = MenuItem.find_by_name('Survey Reports')
    MenuItem.create(:name => 'Available During Conflict Items', :path => "/survey_reports/available_during/", :menu_item => menu)
  end

  def self.down
    MenuItem.find_by_name('Available During Conflict Items').destroy
  end
end
