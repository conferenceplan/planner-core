
json.name           SITE_CONFIG[:conference][:name]
json.start_day      Time.zone.parse(SITE_CONFIG[:conference][:start_date].to_s).strftime('%Y-%m-%d')
json.num_days       SITE_CONFIG[:conference][:number_of_days]
json.utc_offset     Time.zone.parse(SITE_CONFIG[:conference][:start_date].to_s).utc_offset/(60*60) # Time.zone.utc_offset/(60*60)

json.cloudinary_url  @cloudinaryURI #.sub(/http\:\/\/a[0-9]*\./,'') #

json.set! 'mobile' do
    json.set! 'colors' do
        json.partial! 'color', name: 'main_background',             color: @theme.main_background
        json.partial! 'color', name: 'action_bar_bg',               color: @theme.action_bar_bg
        json.partial! 'color', name: 'body_text',                   color: @theme.body_text
        json.partial! 'color', name: 'body_text_secondary',         color: @theme.body_text_secondary
        json.partial! 'color', name: 'card_background',             color: @theme.card_background
        json.partial! 'color', name: 'updated_ribbon',              color: @theme.updated_ribbon
        json.partial! 'color', name: 'hot_ribbon',                  color: @theme.hot_ribbon
        json.partial! 'color', name: 'favourite_on',                color: @theme.favourite_on
        json.partial! 'color', name: 'card_shadow',                 color: @theme.card_shadow
        json.partial! 'color', name: 'favourite_on_bg',             color: @theme.favourite_on_bg
        json.partial! 'color', name: 'favourite_off_bg',            color: @theme.favourite_off_bg
        json.partial! 'color', name: 'favourite_off',               color: @theme.favourite_off
        json.partial! 'color', name: 'hot_ribbon_text',             color: @theme.hot_ribbon_text
        json.partial! 'color', name: 'new_ribbon',                  color: @theme.new_ribbon
        json.partial! 'color', name: 'new_ribbon_text',             color: @theme.new_ribbon_text
        json.partial! 'color', name: 'item_name',                   color: @theme.item_name
        json.partial! 'color', name: 'action_bar_text',             color: @theme.action_bar_text
        json.partial! 'color', name: 'day_text',                    color: @theme.day_text
        json.partial! 'color', name: 'date_text',                   color: @theme.date_text
        json.partial! 'color', name: 'time_text',                   color: @theme.time_text
        json.partial! 'color', name: 'page_flipper_text',           color: @theme.page_flipper_text
        json.partial! 'color', name: 'page_flipper_bg',             color: @theme.page_flipper_bg
        json.partial! 'color', name: 'page_flipper_separators',     color: @theme.page_flipper_separators
        json.partial! 'color', name: 'page_flipper_selection_bar',  color: @theme.page_flipper_selection_bar
        json.partial! 'color', name: 'updated_ribbon_text',         color: @theme.updated_ribbon_text
        json.partial! 'color', name: 'item_format',                 color: @theme.item_format
    end

    json.set! 'card_images' do
        json.array! @formats do |format|
            #json.id                 format.id
            json.format             format.name
            json.large_card         format.external_images.use(:largecard)[0].picture.large_card.url.partition(@partition_val)[2] if format.external_images.use(:largecard)[0]
            json.medium_card        format.external_images.use(:mediumcard)[0].picture.large_card.url.partition(@partition_val)[2] if format.external_images.use(:mediumcard)[0]
        end
    end
    
end
