class AddReportsToMenu < ActiveRecord::Migration
  def self.up
    menu = Menu.find_by_title("Main")
    MenuItem.create(:name => "Reports", :path => "/survey_reports", :menu => menu)
  end

  def self.down
    item = MenuItem.find_by_name("Reports")
    item.destroy
  end
end
