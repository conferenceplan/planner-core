class CreateMobileThemes < ActiveRecord::Migration
  def change
    create_table :mobile_themes do |t|

      t.string :main_background, :default => "#e6e7e8"
      t.string :title_background, :default => "#e6e7e8"
      t.string :primary_text, :default => "#333333"
      t.string :secondary_text, :default => "#bbbbbb"
      t.string :card_background, :default => "#ffffff"
      t.string :updated_ribbon, :default => "#00ff00"
      t.string :hot_ribbon, :default => "#ff0000"
      t.string :favourite_on, :default => "#00adef"
      t.string :card_shadow, :default => "#111111"

      t.timestamps
    end
  end
end
