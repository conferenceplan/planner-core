json.totalpages 1
json.currpage 1

json.rowdata @taginfo do |k|
    json.context    k[0][0]
    json.tag        k[0][1]
    json.people     k[1].collect { |t|
        if (t['pub_first_name'] || t['pub_last_name'])
            t['pub_first_name'] + ' ' + t['pub_last_name'] + ' ' + t['pub_suffix']
        else
            t['first_name'] + ' ' + t['last_name'] + ' ' + t['suffix']
        end
    }
end
