class AddShareAllowedToRegDetail < ActiveRecord::Migration
  def change
    add_column :registration_details, :can_share, :boolean, {:default => false}
  end
end
