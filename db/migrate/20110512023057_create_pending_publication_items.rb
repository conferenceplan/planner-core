class CreatePendingPublicationItems < ActiveRecord::Migration
  def self.up
    create_table :pending_publication_items do |t|
      t.integer  "programme_item_id"

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :pending_publication_items
  end
end
