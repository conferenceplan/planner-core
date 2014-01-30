class AdjustMobileThemeColors < ActiveRecord::Migration
  def up
    add_column :mobile_themes, :favourite_on_bg, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :favourite_off_bg, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :favourite_off, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :hot_ribbon_text, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :new_ribbon, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :new_ribbon_text, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :item_name, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :action_bar_text, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :day_text, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :date_text, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :time_text, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :page_flipper_text, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :page_flipper_bg, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :page_flipper_separators, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :page_flipper_selection_bar, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :updated_ribbon_text, :string, :default => "rgba(184,182,182,1)"
    add_column :mobile_themes, :item_format, :string, :default => "rgba(184,182,182,1)"

    rename_column :mobile_themes, :title_background, :action_bar_bg
    rename_column :mobile_themes, :primary_text, :body_text
    rename_column :mobile_themes, :secondary_text, :body_text_secondary
  end
  
  def down
    remove_column :mobile_themes, :favourite_on_bg
    remove_column :mobile_themes, :favourite_off_bg
    remove_column :mobile_themes, :favourite_off
    remove_column :mobile_themes, :hot_ribbon_text
    remove_column :mobile_themes, :new_ribbon
    remove_column :mobile_themes, :new_ribbon_text
    remove_column :mobile_themes, :item_name
    remove_column :mobile_themes, :action_bar_text
    remove_column :mobile_themes, :day_text
    remove_column :mobile_themes, :date_text
    remove_column :mobile_themes, :time_text
    remove_column :mobile_themes, :page_flipper_text
    remove_column :mobile_themes, :page_flipper_bg
    remove_column :mobile_themes, :page_flipper_separators
    remove_column :mobile_themes, :page_flipper_selection_bar
    remove_column :mobile_themes, :updated_ribbon_text
    remove_column :mobile_themes, :item_format
    
    rename_column :mobile_themes, :action_bar_bg, :title_background
    rename_column :mobile_themes, :body_text, :primary_text
    rename_column :mobile_themes, :body_text_secondary, :secondary_text
  end
end
