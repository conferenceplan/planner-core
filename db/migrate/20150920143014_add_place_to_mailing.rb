class AddPlaceToMailing < ActiveRecord::Migration
  def change
    add_column :mailings, :last_person_idx, :integer, {:default => -1}
  end
end
