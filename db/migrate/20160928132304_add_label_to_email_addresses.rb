class AddLabelToEmailAddresses < ActiveRecord::Migration
  def change
    add_column :email_addresses, :label, :string
  end
end
