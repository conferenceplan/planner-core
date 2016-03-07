class AddBioToPendingImport < ActiveRecord::Migration
  def change
    add_column :import_mappings, :bio, :integer, {:default => -1}
    add_column :import_mappings, :invite_status, :integer, {:default => -1}
    add_column :import_mappings, :invite_category, :integer, {:default => -1}
    add_column :import_mappings, :accept_status, :integer, {:default => -1}
    

    add_column :pending_import_people, :bio, :text
    add_column :pending_import_people, :invite_status, :string, {:default => nil}
    add_column :pending_import_people, :invite_category, :string, {:default => nil}
    add_column :pending_import_people, :accept_status, :string, {:default => nil}
  end
end
