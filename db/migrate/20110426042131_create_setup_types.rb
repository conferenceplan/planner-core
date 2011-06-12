class CreateSetupTypes < ActiveRecord::Migration
  def self.up
    create_table :setup_types do |t|
      t.string :name
      t.string :description

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :setup_types
  end
end
