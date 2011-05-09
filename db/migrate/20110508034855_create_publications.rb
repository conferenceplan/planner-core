class CreatePublications < ActiveRecord::Migration
  def self.up
    drop_table :published_publications
    create_table :publications do |t|
      # The published object is within the Published name space (items, etc)
      t.column :published_id, :integer
      t.column :published_type, :string     

      # The source object is the original element from which the publication was done
      t.column :original_id, :integer
      t.column :original_type, :string
      
      # Also want to know who did the publish and when
      t.references :user
      t.datetime :publication_date

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :publications
    create_table :publications do |t|
      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end
end
