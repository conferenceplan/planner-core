class CreateConflictExceptions < ActiveRecord::Migration
  def change
    create_table :conflict_exceptions do |t|
      t.string  :conflict_type
      t.integer :affected # TODO - create an unique key base on these three attributes
      t.integer :src1
      t.integer :src2
      t.integer :idx, :limit => 8

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end
end
