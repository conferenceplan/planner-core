class ModifyAdminMenu < ActiveRecord::Migration
  def self.up
    adminMenu = MenuItem.all(:conditions => { :name => "Admin" } ).first
    adminMenu.path = '/'
    adminMenu.save
    MenuItem.create( :name => "Users", :path => "/usersadmin", :menu_item => adminMenu)
    MenuItem.create( :name => "Tags", :path => "/", :menu_item => adminMenu)
  end

  def self.down
  end
end
