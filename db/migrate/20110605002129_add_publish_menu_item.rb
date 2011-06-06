class AddPublishMenuItem < ActiveRecord::Migration
  def self.up
    menu = MenuItem.find_by_name('Schedule')
    MenuItem.create(:name => 'Publish', :path => "/publisher", :menu_item => menu)
  end

  def self.down
    MenuItem.find_by_name('Publish').destroy
  end
end
