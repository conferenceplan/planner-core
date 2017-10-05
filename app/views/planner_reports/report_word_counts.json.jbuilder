json.totalpages 1
json.currpage 1
    
json.rowdata @res do |r|
    json.title              r['title']
    json.title_words        r['title_words']
    json.short_title        r['short_title']
    json.short_title_words  r['short_title_words']
    json.description             r['description']
    json.description_words       r['description_words']
    json.short_description       r['short_description']
    json.short_description_words r['short_description_words']
end
