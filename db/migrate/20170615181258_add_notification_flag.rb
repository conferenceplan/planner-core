class AddNotificationFlag < ActiveRecord::Migration
  def change
    add_column :mail_configs, :receive_notifications, :boolean, {:default => true}
  end
end
