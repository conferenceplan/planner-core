class AddPubReferenceNumbers < ActiveRecord::Migration
  def self.up
    add_column :programme_items, :pub_reference_number, :integer
    add_column :published_programme_items, :pub_reference_number, :integer
  end

  def self.down
    remove_column :programme_items,:pub_reference_number
    remove_column :published_programme_items, :pub_reference_number
  end
end
