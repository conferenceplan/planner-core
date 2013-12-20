
json.card_background @theme.card_background.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0]
json.card_shadow @theme.card_shadow.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0]
json.favourite_on @theme.favourite_on.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0]
json.hot_ribbon @theme.hot_ribbon.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0]
json.main_background @theme.main_background.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0]
json.primary_text @theme.primary_text.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0]
json.secondary_text @theme.secondary_text.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0]
json.title_background @theme.title_background.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16) +
    a[1].to_i.to_s(16) +
    a[2].to_i.to_s(16) +
    (a[3].to_i * 255).to_s(16)
     }[0]
     
     