class AddTestEmail < ActiveRecord::Migration
  def self.up
    add_column :mail_configs, :test_email, :string
  end

  def self.down
    remove_column :mail_configs, :test_email
  end
end
