class AddDatasourceMenu < ActiveRecord::Migration
  def self.up
     adminMenu = MenuItem.all(:conditions => { :name => "Admin" } ).first
     MenuItem.create( :name => "Import Datasource Management", :path => "/datasources", :menu_item => adminMenu)
  end

  def self.down
  end
end
