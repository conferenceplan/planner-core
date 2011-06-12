class AddSetupTabs < ActiveRecord::Migration
  def self.up
    menu = MenuItem.all(:conditions => { :name => "Rooms" } ).first
    MenuItem.create( :name => "Setup Types", :path => "/setup_types", :menu_item => menu)
  end

  def self.down
  end
end
