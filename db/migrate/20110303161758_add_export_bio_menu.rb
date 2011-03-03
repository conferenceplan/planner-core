class AddExportBioMenu < ActiveRecord::Migration
  def self.up
     communicationMenu = MenuItem.all(:conditions => { :name => "Communications" } ).first
     MenuItem.create( :name => "Export Bio List", :path => "/participants/exportbiolist", :menu_item => communicationMenu)
 end

  def self.down
  end
end
