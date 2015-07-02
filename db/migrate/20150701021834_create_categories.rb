class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.integer :category_name_id
      t.integer :categorized_id
      t.string  :categorized_type
      
      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end

    add_index :categories, :category_name_id
    add_index :categories, [:category_name_id, :categorized_type]
    add_index :categories, :categorized_id
    add_index :categories, [:categorized_id, :categorized_type]

  end
end
