class AddEmailFlagToMailing < ActiveRecord::Migration
  def change
    add_column :mailings, :include_email, :boolean, {:default => true}
  end
end
