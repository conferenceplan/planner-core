class CorrectlyMoveVenueMenu < ActiveRecord::Migration
  def self.up
   execute <<-SQL
      DELETE From menus; 
    SQL
    execute <<-SQL
      DELETE From menu_items;
    SQL
    menu = Menu.create(:title => "Main")
    MenuItem.create( :name => "Home", :path => "/", :menu => menu)
    MenuItem.create( :name => "Items", :path => "/programme_items", :menu => menu)
    partMenu = MenuItem.create( :name => "Participants", :path => "/participants", :menu => menu)
    MenuItem.create( :name => "New", :path => "/participants/new", :menu_item => partMenu)
    MenuItem.create( :name => "Import", :path => "/pending_import_people/import", :menu_item => partMenu)
    MenuItem.create( :name => "Set Invite Pending to Invited", :path => "/participants/SetInvitePendingToInvited", :menu_item => partMenu)
    MenuItem.create( :name => "Invitation Categories", :path => "/invitation_categories", :menu_item => partMenu)
    MenuItem.create( :name => "Schedule", :path => "/", :menu => menu)
    comMenu = MenuItem.create( :name => "Communications", :path => "/", :menu => menu)
    MenuItem.create(:name => "Export email list", :path => "/participants/exportemailxml", :menu_item => comMenu)
    roomMenu = MenuItem.create(:name => "Rooms", :path => "/rooms", :menu => menu)
    MenuItem.create(:name => "Venues", :path => "/venue", :menu_item => roomMenu)
    adminMenu = MenuItem.create(:name => "Admin", :path => "/", :menu => menu)
    MenuItem.create( :name => "Users", :path => "/usersadmin", :menu_item => adminMenu)
    MenuItem.create( :name => "Tags", :path => "/", :menu_item => adminMenu)
  end

  def self.down
    execute <<-SQL
      DELETE From menus; 
    SQL
    execute <<-SQL
      DELETE From menu_items;
    SQL
    menu = Menu.create(:title => "Main")
    MenuItem.create( :name => "Home", :path => "/", :menu => menu)
    MenuItem.create( :name => "Items", :path => "/programme_items", :menu => menu)
    partMenu = MenuItem.create( :name => "Participants", :path => "/participants", :menu => menu)
    MenuItem.create( :name => "New", :path => "/participants/new", :menu_item => partMenu)
    MenuItem.create( :name => "Import", :path => "/pending_import_people/import", :menu_item => partMenu)
    MenuItem.create( :name => "Set Invite Pending to Invited", :path => "/participants/SetInvitePendingToInvited", :menu_item => partMenu)
    MenuItem.create( :name => "Invitation Categories", :path => "/invitation_categories", :menu_item => partMenu)
    MenuItem.create( :name => "Schedule", :path => "/", :menu => menu)
    comMenu = MenuItem.create( :name => "Communications", :path => "/", :menu => menu)
    MenuItem.create(:name => "Export email list", :path => "/participants/exportemailxml", :menu_item => comMenu)
    MenuItem.create(:name => "Rooms", :path => "/rooms", :menu => menu)
    MenuItem.create(:name => "Venues", :path => "/venue", :menu => menu)
    adminMenu = MenuItem.create(:name => "Admin", :path => "/", :menu => menu)
    MenuItem.create( :name => "Users", :path => "/usersadmin", :menu_item => adminMenu)
    MenuItem.create( :name => "Tags", :path => "/", :menu_item => adminMenu)
  end
end
