class AddAdminToMenu < ActiveRecord::Migration
  def self.up
    menu = Menu.find_by_title("Main")
    MenuItem.create(:name => "Admin", :path => "/usersadmin", :menu => menu)
  end

  def self.down
  end 
end
  
