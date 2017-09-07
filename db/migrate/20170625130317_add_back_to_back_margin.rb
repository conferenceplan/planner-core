class AddBackToBackMargin < ActiveRecord::Migration
  def change
    add_column :site_configs, :back2back_margin, :integer, {:default => 0}
  end
end
