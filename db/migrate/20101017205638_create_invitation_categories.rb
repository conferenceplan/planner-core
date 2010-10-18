class CreateInvitationCategories < ActiveRecord::Migration
  def self.up
    create_table :invitation_categories do |t|
      t.string  :name
      t.integer :position
      t.timestamps
      t.column :lock_version, :integer, { :default => 0 }
    end
  end

  def self.down
    drop_table :invitation_categories
  end
end
