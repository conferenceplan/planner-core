#
# This links the published object back to the source (and vice versa)
#
class CreatePublishedPublications < ActiveRecord::Migration
  def self.up
    create_table :published_publications do |t|
      # The published object is within the Published name space (items, etc)
      t.column :published_id, :integer
      t.column :published_type, :string     

      # The source object is the original element from which the publication was done
      t.column :original_id, :integer
      t.column :original_type, :string
      
      # Also want to know who did the publish and when
      t.references :User
      t.datetime :publication_date

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :published_publications
  end
end
