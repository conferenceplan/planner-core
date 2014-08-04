class AddReplyToToMailConfig < ActiveRecord::Migration
  def change
    add_column :mail_configs, :reply_to, :string, :limit => 255
  end
end
