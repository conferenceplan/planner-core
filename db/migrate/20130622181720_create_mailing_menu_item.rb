class CreateMailingMenuItem < ActiveRecord::Migration
  def self.up
     partMenu = MenuItem.all(:conditions => { :name => "Communications" } ).first
     MenuItem.create( :name => "Manage Mailings", :path => "/mailings", :menu_item => partMenu)
  end

  def self.down
     MenuItem.find_by_name("Manage Mailings").destroy
  end
end
