class AddColorsToMobileTheme < ActiveRecord::Migration
  def change
    add_column :mobile_themes, :menu_drawer_bg, :string, :default => "rgba(239,239,239,1)"
    add_column :mobile_themes, :menu_drawer_selected, :string, :default => "rgba(0,173,229,1)"
    add_column :mobile_themes, :menu_drawer_text, :string, :default => "rgba(35,31,32,1)"
  end
end
