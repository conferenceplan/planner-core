class AddMigrationFlagToFeature < ActiveRecord::Migration
  def change
    add_column :features, :migrated, :boolean, {:default => false}
  end
end
