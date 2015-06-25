class Api::ConferenceController < ApplicationController
  def index
    @mobilePages = MobilePage.find :all, :order => 'position asc'
    @scale = params[:scale].to_f
    @theme = MobileTheme.where('isdefault = ?', true).first
    if !@theme
      @theme = MobileTheme.new({
        isdefault: false,
        action_bar_bg:        "rgba(230,231,232,1)",
        action_bar_text:      "rgba(184,182,182,1)",
        body_text:            "rgba(51,51,51,1)",
        body_text_secondary:  "rgba(187,187,187,1)",
        card_background:      "rgba(255,255,255,1)",
        card_shadow:          "rgba(17,17,17,1)",
        date_text:            "rgba(184,182,182,1)",
        day_text:             "rgba(184,182,182,1)",
        favourite_off:        "rgba(184,182,182,1)",
        favourite_off_bg:     "rgba(184,182,182,1)",
        favourite_on:         "rgba(00,173,239,1)",
        favourite_on_bg:      "rgba(184,182,182,1)",
        hot_ribbon:           "rgba(255,0,0,1)",
        hot_ribbon_text:      "rgba(184,182,182,1)",
        item_format:          "rgba(184,182,182,1)",
        item_name:            "rgba(184,182,182,1)",
        main_background:      "rgba(230,231,232,1)",
        menu_drawer_bg:       "rgba(239,239,239,1)",
        menu_drawer_selected: "rgba(0,173,229,1)",
        menu_drawer_text:     "rgba(35,31,32,1)",
        new_ribbon:           "rgba(184,182,182,1)",
        new_ribbon_text:      "rgba(184,182,182,1)",
        page_flipper_bg:      "rgba(184,182,182,1)",
        page_flipper_selection_bar: "rgba(184,182,182,1)",
        page_flipper_separators:    "rgba(184,182,182,1)",
        page_flipper_text:          "rgba(184,182,182,1)",
        time_text:                  "rgba(184,182,182,1)",
        updated_ribbon:             "rgba(0,255,0,1)",
        updated_ribbon_text:        "rgba(184,182,182,1)"
      })
    end
    
    @logo = ConferenceLogo.find :first
    @formats = Format.find :all
    @default_bio_image = DefaultBioImage.find :first
    @cloudinaryURI = get_base_image_url
    @partition_val = /upload/
  end
  
  def show
    @mobilePages = MobilePage.find :all, :order => 'position asc'
    @scale = params[:scale].to_f
    @theme = MobileTheme.where('isdefault = ?', true).first
    if !@theme
      @theme = MobileTheme.new({
        isdefault: false,
        action_bar_bg:        "rgba(230,231,232,1)",
        action_bar_text:      "rgba(184,182,182,1)",
        body_text:            "rgba(51,51,51,1)",
        body_text_secondary:  "rgba(187,187,187,1)",
        card_background:      "rgba(255,255,255,1)",
        card_shadow:          "rgba(17,17,17,1)",
        date_text:            "rgba(184,182,182,1)",
        day_text:             "rgba(184,182,182,1)",
        favourite_off:        "rgba(184,182,182,1)",
        favourite_off_bg:     "rgba(184,182,182,1)",
        favourite_on:         "rgba(00,173,239,1)",
        favourite_on_bg:      "rgba(184,182,182,1)",
        hot_ribbon:           "rgba(255,0,0,1)",
        hot_ribbon_text:      "rgba(184,182,182,1)",
        item_format:          "rgba(184,182,182,1)",
        item_name:            "rgba(184,182,182,1)",
        main_background:      "rgba(230,231,232,1)",
        menu_drawer_bg:       "rgba(239,239,239,1)",
        menu_drawer_selected: "rgba(0,173,229,1)",
        menu_drawer_text:     "rgba(35,31,32,1)",
        new_ribbon:           "rgba(184,182,182,1)",
        new_ribbon_text:      "rgba(184,182,182,1)",
        page_flipper_bg:      "rgba(184,182,182,1)",
        page_flipper_selection_bar: "rgba(184,182,182,1)",
        page_flipper_separators:    "rgba(184,182,182,1)",
        page_flipper_text:          "rgba(184,182,182,1)",
        time_text:                  "rgba(184,182,182,1)",
        updated_ribbon:             "rgba(0,255,0,1)",
        updated_ribbon_text:        "rgba(184,182,182,1)"
      })
    end
    @logo = ConferenceLogo.find :first
    @default_bio_image = DefaultBioImage.find :first
    @formats = Format.find :all
    @cloudinaryURI = get_base_image_url
    @partition_val = /upload/
  end
end
