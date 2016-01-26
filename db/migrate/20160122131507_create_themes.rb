class CreateThemes < ActiveRecord::Migration
  def change
    create_table :themes do |t|
      t.integer :theme_name_id
      t.integer :themed_id
      t.string  :themed_type
      
      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end

    add_index :themes, :theme_name_id
    add_index :themes, [:theme_name_id, :themed_type]
    add_index :themes, :themed_id
    add_index :themes, [:themed_id, :themed_type]
  end
end
