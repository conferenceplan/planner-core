class RenamePersonColumn < ActiveRecord::Migration
  def self.up
    rename_column :registration_details, :Person_id, :person_id
  end

  def self.down
    rename_column :registration_details, :person_id, :Person_id
  end
end
