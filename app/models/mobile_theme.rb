class MobileTheme < ActiveRecord::Base
  attr_accessible :action_bar_bg, :action_bar_text, :body_text, :body_text_secondary, :created_at, :date_text, :day_text, :favourite_off, :favourite_off_bg, 
                  :favourite_on_bg, :hot_ribbon_text, :id, :item_format, :item_name, :new_ribbon, :new_ribbon_text, :page_flipper_bg, :page_flipper_selection_bar, 
                  :page_flipper_separators, :page_flipper_text, :time_text, :updated_at, :updated_ribbon_text, :card_background, :card_shadow, :favourite_on, 
                  :hot_ribbon, :main_background, :updated_ribbon, :default_bio_image, :menu_drawer_bg, :menu_drawer_selected, :menu_drawer_text,
                  :name, :isdefault

  attr_accessor :scale

  # default bio image needs to be moved if we have multiple themes - TODO
  mount_uploader :default_bio_image, BioPictureUploader

  audited except: :default_bio_image

  # if this is a default then set the others to non-default
  before_save do |theme|
    theme.isdefault_will_change!
    MobileTheme.where(:isdefault => true).update_all(:isdefault => false) if theme.isdefault
  end

end
