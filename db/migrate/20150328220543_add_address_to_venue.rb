class AddAddressToVenue < ActiveRecord::Migration
  def change
    add_column :addresses, :venue_id, :integer
  end
end
