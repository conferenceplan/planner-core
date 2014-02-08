class MobileTheme < ActiveRecord::Base
  # attr_accessible :main_background, :title_background, :primary_text, :secondary_text, :card_background, :updated_ribbon, :hot_ribbon, :favourite_on, :card_shadow

  attr_accessible :action_bar_bg, :action_bar_text, :body_text, :body_text_secondary, :created_at, :date_text, :day_text, :favourite_off, :favourite_off_bg, 
                  :favourite_on_bg, :hot_ribbon_text, :id, :item_format, :item_name, :new_ribbon, :new_ribbon_text, :page_flipper_bg, :page_flipper_selection_bar, 
                  :page_flipper_separators, :page_flipper_text, :time_text, :updated_at, :updated_ribbon_text, :card_background, :card_shadow, :favourite_on, 
                  :hot_ribbon, :main_background, :updated_ribbon


  has_one  :default_bio_image, :class_name => 'ExternalImage', :as => :imageable,  :dependent => :delete

end
