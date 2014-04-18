class CreatePersonConstraints < ActiveRecord::Migration
  def change
    create_table :person_constraints do |t|
      t.integer :max_items_per_day
      t.integer :max_items_per_con
      t.integer :person_id

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end
end
