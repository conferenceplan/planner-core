class AddLatitudeAndLongitudeToPostalAddress < ActiveRecord::Migration
  def change
    add_column :postal_addresses, :latitude, :float
    add_column :postal_addresses, :longitude, :float
  end
end
