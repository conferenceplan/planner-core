class AddPrefixToPendingAndMapping < ActiveRecord::Migration
  def change
    add_column :pending_import_people, :prefix, :string, {:default => ""}
    add_column :import_mappings, :prefix, :integer, {:default => -1}
    add_column :pending_import_people, :pub_prefix, :string, {:default => ""}
    add_column :import_mappings, :pub_prefix, :integer, {:default => -1}
  end
end
