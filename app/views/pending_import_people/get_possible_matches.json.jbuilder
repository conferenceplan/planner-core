
json.total @total

json.rows @matches do |match|
    json.id             match.id
    json.pending_type   ''
    json.first_name     match.first_name
    json.last_name      match.last_name
    json.suffix         match.suffix
    json.job_title      match.job_title
    json.company        match.company

    reg = match.registrationDetail
    if reg
        json.registration_number    reg.registration_number
        json.registration_type  reg.registration_type
    end
    addr = match.getDefaultPostalAddress
    if addr
        json.line1          addr.line1
        json.line2          addr.line2
        json.line3          addr.line3
        json.city           addr.city
        json.state          addr.state
        json.country        addr.country
        json.postcode       addr.postcode
    end
    email = match.getDefaultEmail
    if email
        json.email          email.email
    end
    if match.peoplesource
        json.datasource_dbid    match.peoplesource.datasource_dbid
        json.datasource_id      match.peoplesource.datasource_id
        json.datasource_name    match.datasource.name
    end
    if match.pseudonym
        json.pub_first_name     match.pseudonym.first_name
        json.pub_last_name      match.pseudonym.last_name
        json.pub_suffix         match.pseudonym.suffix
    end
    if match.phone_numbers.size > 0
        phone = match.phone_numbers.detect { |ph| ph.phone_type == PhoneTypes['Work'] }
        json.phone     phone.number if phone
    end
end

