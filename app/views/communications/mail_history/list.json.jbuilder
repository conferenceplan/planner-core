json.totalpages @nbr_pages
json.currpage @page
json.totalrecords @count
json.currentSelection @currentId if @currentId
    
json.rowdata @mailItems do |item|
    
    json.id   item.id
    json.set! "item[email_status]", item.email_status ? item.email_status.name : 'unknown'
    json.set! "item[date_sent]", item.date_sent.strftime('%e %b %Y, %H:%M')
    
    json.set! "item[testrun]", item.testrun ? "Y" : "N"
    json.set! "item[content]", item.content
    json.set! "item[subject]", item.subject
    
    json.set! "item[person][first_name]", item.person.first_name
    json.set! "item[person][last_name]", item.person.last_name
    json.set! "item[person][suffix]", item.person.suffix

    if item.person.pseudonym
        json.set! "item[person][pseudonym_attributes][first_name]", item.person.pseudonym.first_name
        json.set! "item[person][pseudonym_attributes][last_name]", item.person.pseudonym.last_name
        json.set! "item[person][pseudonym_attributes][suffix]", item.person.pseudonym.suffix
    end

    json.set! "item[mailing][mail_use]", item.mailing ? item.mailing.mail_template.mail_use.name : ''
    json.set! "item[mailing][mailing_number]", item.mailing ? item.mailing.mailing_number : ''

end
