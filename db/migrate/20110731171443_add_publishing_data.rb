class AddPublishingData < ActiveRecord::Migration
  def self.up
     add_column :publication_dates, :newitems, :integer, :default => 0
     add_column :publication_dates, :modifieditems, :integer, :default => 0
     add_column :publication_dates, :removeditems, :integer, :default => 0
  end

  def self.down
     remove_column :publication_dates, :newitems
     remove_column :publication_dates, :modifieditems
     remove_column :publication_dates, :removeditems
  end
end
