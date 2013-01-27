class AddInfoEmail < ActiveRecord::Migration
  def self.up
    add_column :mail_configs, :info, :string
  end

  def self.down
    remove_column :mail_configs, :info
  end
end
