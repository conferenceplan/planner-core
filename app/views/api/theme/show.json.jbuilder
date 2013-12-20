
json.card_background @theme.card_background.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0] if @theme.card_background
json.card_shadow @theme.card_shadow.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0] if @theme.card_shadow
json.favourite_on @theme.favourite_on.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0] if @theme.favourite_on
json.hot_ribbon @theme.hot_ribbon.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0] if @theme.hot_ribbon
json.main_background @theme.main_background.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0] if @theme.main_background
json.primary_text @theme.primary_text.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0] if @theme.primary_text
json.secondary_text @theme.secondary_text.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0] if @theme.secondary_text
json.title_background @theme.title_background.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0] if @theme.title_background
     
     