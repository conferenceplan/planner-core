class CreateTagContexts < ActiveRecord::Migration
  def self.up
    create_table :tag_contexts do |t|
      t.string :name

      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :tag_contexts
  end
end
