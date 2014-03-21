class AddNameToMobileTheme < ActiveRecord::Migration
  def change
    add_column :mobile_themes, :name, :string
    add_column :mobile_themes, :isdefault, :boolean, :default => false
  end
end
