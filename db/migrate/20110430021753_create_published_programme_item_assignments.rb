class CreatePublishedProgrammeItemAssignments < ActiveRecord::Migration
  def self.up
    create_table :published_programme_item_assignments do |t|
      t.references :published_person
      t.references :published_programme_item
      t.integer :role

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :published_programme_item_assignments
  end
end
