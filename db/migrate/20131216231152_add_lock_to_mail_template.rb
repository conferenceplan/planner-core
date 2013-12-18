class AddLockToMailTemplate < ActiveRecord::Migration
  def change
    add_column :mail_templates, :lock_version, :integer, { :default => 0 }
  end
end
