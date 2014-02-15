class AddTransistionStatusToMailtemplate < ActiveRecord::Migration
  def change
     add_column :mail_templates, :transiton_invite_status_id, :integer
  end
end
