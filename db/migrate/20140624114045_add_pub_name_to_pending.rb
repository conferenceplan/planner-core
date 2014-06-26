class AddPubNameToPending < ActiveRecord::Migration
  def change

    add_column :pending_import_people, :pub_first_name, :string, :limit => 255
    add_column :pending_import_people, :pub_last_name, :string, :limit => 255
    add_column :pending_import_people, :pub_suffix, :string, :limit => 255
    
    add_column :pending_import_people, :company, :string, :limit => 255
    add_column :pending_import_people, :job_title, :string, :limit => 255

  end
end
