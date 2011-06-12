class AddVenuesToMenu < ActiveRecord::Migration
  def self.up
    menu = Menu.find_by_title("Main")
    MenuItem.create(:name => "Venues", :path => "/venue", :menu => menu)
  end

  def self.down
    MenuItem.find_by_name("Venues").destroy
  end
end
