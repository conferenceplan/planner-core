json.total @total

json.rows @mail_history do |history|

    json.id                 history.id
    json.lock_version       history.lock_version

    json.email_status       history.email_status ? history.email_status.name : 'unknown'
    json.date_sent          history.date_sent #.strftime('%e %b %Y, %H:%M')
    
    json.testrun            history.testrun ? "Y" : "N"
    json.content            history.content

    json.person do
        json.first_name history.person.first_name
        json.last_name history.person.last_name
        json.suffix history.person.suffix

        if history.person.pseudonym
            json.pseudonym do
                json.first_name history.person.pseudonym.first_name
                json.last_name history.person.pseudonym.last_name
                json.suffix history.person.pseudonym.suffix
            end
        end
    end
    
    json.mailing do
        json.mail_use history.mailing ? history.mailing.mail_template.mail_use.name : ''
        json.mailing_number history.mailing ? history.mailing.mailing_number : ''
    end

end