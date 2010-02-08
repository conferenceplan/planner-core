class CreateTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|

      t.column :tagable_id, :integer
      t.column :tagable_type, :string

      t.column :term_id, :integer

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :tags
  end
end
