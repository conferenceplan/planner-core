class AddAdminToMenu < ActiveRecord::Migration
  def self.up
#    TODO change to get the menu from the DB
    menu = Menu.find_by_title("Main")
    MenuItem.create(:name => "Admin", :path => "/usersadmin", :menu => menu)
  end

  def self.down
  end 
end
  
