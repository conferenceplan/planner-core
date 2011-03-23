class UpdateExportBiosMenu < ActiveRecord::Migration
  def self.up
    item = MenuItem.find_by_name( "Export Bio List" )
    item.path = "/edited_bios/selectExportBioList"
    item.save
  end

  def self.down
  end
end
