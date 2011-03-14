class AddFacebookToEditedbios < ActiveRecord::Migration
  def self.up
     add_column :edited_bios, :facebook, :text

  end

  def self.down
    remove_column :edited_bios, :facebook
  end
end
