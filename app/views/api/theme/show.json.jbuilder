
json.card_background @theme.card_background.scan(/^rgba?\(\s*(\d{1,3})\s*,\s*(\d{1,3})\s*,\s*(\d{1,3})\s*(?:,\s*(\d+(?:\.\d+)?)\s*)?\)$/).collect{ |a| 
    a[0].to_i.to_s(16).rjust(2,'0') +
    a[1].to_i.to_s(16).rjust(2,'0') +
    a[2].to_i.to_s(16).rjust(2,'0') +
    (a[3].to_i * 255).to_s(16)
     }[0] if @theme.card_background

     
     