class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :linkedto_id
      t.string  :linkedto_type

      # t.integer :linkedfrom_id
      # t.string  :linkedfrom_type

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end

    add_index :links, :linkedto_id
    add_index :links, [:linkedto_id, :linkedto_type]

  end
end
