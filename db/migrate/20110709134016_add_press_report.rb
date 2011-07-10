class AddPressReport < ActiveRecord::Migration
  def self.up
    menu = MenuItem.find_by_name("Survey Reports")
    MenuItem.create(:name => "Talk to Media", :path => "/survey_reports/interviewable/", :menu_item => menu)
  end

  def self.down
    item = MenuItem.find_by_name("Talk to Media").destroy
  end
end
