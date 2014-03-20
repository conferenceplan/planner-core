class CreateImportMappings < ActiveRecord::Migration
  def change
    create_table :import_mappings do |t|
      
      # Map from the data attribute to the column from a CSV file
      t.column :first_name, :integer, {:default => -1}
      t.column :last_name, :integer, {:default => -1}
      t.column :suffix, :integer, {:default => -1}
      t.column :line1, :integer, {:default => -1}
      t.column :line2, :integer, {:default => -1}
      t.column :city, :integer, {:default => -1}
      t.column :state, :integer, {:default => -1}
      t.column :postcode, :integer, {:default => -1}
      t.column :country, :integer, {:default => -1}
      t.column :phone, :integer, {:default => -1}
      t.column :email, :integer, {:default => -1}
      t.column :registration_number, :integer, {:default => -1}
      t.column :registration_type, :integer, {:default => -1}
      t.column :datasource_dbid, :integer, {:default => -1}
      t.column :pub_first_name, :integer, {:default => -1}
      t.column :pub_last_name, :integer, {:default => -1}
      t.column :pub_suffix, :integer, {:default => -1}
      
      t.column :datasource_id, :integer

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end
end
