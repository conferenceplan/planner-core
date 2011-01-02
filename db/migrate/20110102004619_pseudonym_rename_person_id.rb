class PseudonymRenamePersonId < ActiveRecord::Migration
  def self.up
    rename_column :pseudonyms, :Person_id, :person_id
  end

  def self.down
    rename_column :pseudonyms, :person_id, :Person_id
  end
end
