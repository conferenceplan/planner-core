class AddSourceForExclusions < ActiveRecord::Migration
  def self.up
    add_column :exclusions, :source, :text
  end

  def self.down
    drop_column :exclusions, :source
  end
end
