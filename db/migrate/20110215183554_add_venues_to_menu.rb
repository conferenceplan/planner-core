class AddVenuesToMenu < ActiveRecord::Migration
  def self.up
    menu = Menu.find_by_title("Main")
    MenuItem.create(:name => "Venues", :path => "/venue", :menu => menu)
  end

  def self.down
  end
end
