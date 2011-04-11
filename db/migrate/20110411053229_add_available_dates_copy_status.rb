class AddAvailableDatesCopyStatus < ActiveRecord::Migration
  def self.up
     add_column :survey_copy_statuses, :availableDatesCopied, :boolean, :default => false
  end

  def self.down
    remove_column :survey_copy_statuses, :availableDatesCopied
  end
end
