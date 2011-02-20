class UpdateItemsToMenu < ActiveRecord::Migration
  def self.up
    menu = MenuItem.all(:conditions => { :name => "Items" } ).first
    MenuItem.create(:name => "New", :path => "/programme_items/new", :menu_item => menu)
    MenuItem.create( :name => "Formats", :path => "/formats", :menu_item => menu)
  end

  def self.down
  end
end
