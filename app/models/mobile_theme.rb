class MobileTheme < ActiveRecord::Base
  attr_accessible :main_background, :title_background, :primary_text, :secondary_text, :card_background, :updated_ribbon, :hot_ribbon, :favourite_on, :card_shadow
end
