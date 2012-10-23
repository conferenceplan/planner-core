class AddSecondEmailToPending < ActiveRecord::Migration
  def self.up
     add_column :pending_import_people, :alt_email, :text
  end

  def self.down
     remove_column :pending_import_people , :alt_email
  end
end
