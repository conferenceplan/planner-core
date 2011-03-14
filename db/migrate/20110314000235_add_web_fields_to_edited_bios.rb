class AddWebFieldsToEditedBios < ActiveRecord::Migration
  def self.up
     add_column :edited_bios, :website, :text
     add_column :edited_bios, :twitterinfo, :text
     add_column :edited_bios, :othersocialmedia, :text
     add_column :edited_bios, :photourl, :text
  end

  def self.down
     remove_column :edited_bios, :website
     remove_column :edited_bios, :twitterinfo
     remove_column :edited_bios, :othersocialmedia
     remove_column :edited_bios, :photourl
  end
end
