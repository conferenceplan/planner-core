class CreateMenuItems < ActiveRecord::Migration
  def self.up
    create_table :menu_items do |t|
      
      t.string :name, { :default => "" }
      t.string :path, { :default => "/" }

      t.references :menu
      t.references :menu_item

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
    menu = Menu.create(:title => "Main")
    MenuItem.create( :name => "Home", :path => "/", :menu => menu)
    MenuItem.create( :name => "Items", :path => "/programme_items", :menu => menu)
    partMenu = MenuItem.create( :name => "Participants", :path => "/participants", :menu => menu)
    MenuItem.create( :name => "New", :path => "/participants/new", :menu_item => partMenu)
    MenuItem.create( :name => "Schedule", :path => "/", :menu => menu)
    MenuItem.create( :name => "Communications", :path => "/", :menu => menu)
  end

  def self.down
    drop_table :menu_items
  end
end
