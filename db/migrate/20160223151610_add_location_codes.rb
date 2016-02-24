class AddLocationCodes < ActiveRecord::Migration
  def change
    add_column :postal_addresses, :state_code, :string
    add_column :postal_addresses, :country_code, :string
  end
end
