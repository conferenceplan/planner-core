
json.total @total

json.rows @pendingImportPeople do |pending|

    json.id                 pending.id
    json.lock_version       pending.lock_version
    json.pending_type       pending.pendingtype.name if pending.pendingtype_id
    json.email              pending.email
    json.first_name         pending.first_name
    json.last_name          pending.last_name
    json.suffix             pending.suffix
    json.prefix             pending.prefix
    json.pub_first_name     pending.pub_first_name
    json.pub_last_name      pending.pub_last_name
    json.pub_suffix         pending.pub_suffix
    json.pub_prefix         pending.pub_prefix
    json.job_title          pending.job_title
    json.company            pending.company
    json.line1              pending.line1
    json.line2              pending.line2
    json.line3              pending.line3
    json.city               pending.city
    json.state              pending.state
    json.country            pending.country
    json.postcode           pending.postcode
    json.phone              pending.phone
    json.datasource_dbid    pending.datasource_dbid
    json.registration_type  pending.registration_type
    json.registration_number    pending.registration_number
    json.bio                pending.bio
    json.invite_status      pending.invite_status
    json.invite_category    pending.invite_category
    json.accept_status      pending.accept_status

end
