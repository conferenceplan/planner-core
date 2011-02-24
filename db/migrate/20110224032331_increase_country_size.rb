class IncreaseCountrySize < ActiveRecord::Migration
  def self.up
    change_column :postal_addresses, :country, :string
  end

  def self.down
  end
end
