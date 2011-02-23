class AddTagStatusToCopyStatuses < ActiveRecord::Migration
  def self.up
    add_column :survey_copy_statuses, :tagsCopied, :boolean, :default => false
  end

  def self.down
    remove_column :survey_copy_statuses, :tagsCopied
  end
end
