class AddPublicDates < ActiveRecord::Migration
  def change
    add_column :site_configs, :public_start_date, :datetime
    add_column :site_configs, :public_number_of_days, :integer, {:default => 1}
  end
end
