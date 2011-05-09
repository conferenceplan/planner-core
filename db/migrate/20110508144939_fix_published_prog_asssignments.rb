class FixPublishedProgAsssignments < ActiveRecord::Migration
  def self.up
     remove_column :published_programme_item_assignments, :role
     add_column :published_programme_item_assignments, :role_id, :integer
     remove_column :published_programme_item_assignments, :published_person_id
     add_column :published_programme_item_assignments, :person_id, :integer
  end

  def self.down
  end
end
