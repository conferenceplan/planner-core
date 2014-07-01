json.totalpages 1
json.currpage 1
    
json.rowdata @res do |r|
    json.title              r['title']
    json.title_words        r['title_words']
    json.short_title        r['short_title']
    json.short_title_words  r['short_title_words']
    json.precis             r['precis']
    json.precis_words       r['precis_words']
    json.short_precis       r['short_precis']
    json.short_precis_words r['short_precis_words']
end
