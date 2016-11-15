class AddNewSocialMediaHandlesToEditedBio < ActiveRecord::Migration
  def change
    add_column :edited_bios, :twitch, :text, {:default => nil}
    add_column :edited_bios, :youtube, :text, {:default => nil}
    add_column :edited_bios, :instagram, :text, {:default => nil}
    add_column :edited_bios, :flickr, :text, {:default => nil}
    add_column :edited_bios, :reddit, :text, {:default => nil}
  end
end
