require 'enum'
require 'pending_type'

class UpdatePendingimport < ActiveRecord::Migration
  def self.up
      add_column :pending_import_people , :datasource_id, :integer
      add_column :pending_import_people, :datasource_dbid, :integer
      add_column :pending_import_people, :pendingtype_id, :integer
      PendingType.enumeration_model_updates_permitted = true
      PendingType.create(:name => 'PossibleAddressUpdate',:position => 1)
      PendingType.create(:name => 'PossibleMatchExisting', :position => 2)
  end

  def self.down
    remove_column :pending_import_people , :datasource_id
    remove_column :pending_import_people, :datasource_dbid
    remove_column :pending_import_poeple, :pendingtype_id, :integer
  end
end
