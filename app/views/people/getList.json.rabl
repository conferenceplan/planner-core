
collection @people

attributes :id, :comments, :first_name, :last_name, :suffix

node :invitation_category do |person|
    person.invitation_category.name if person.invitation_category
end

node :invite_status do |person|
    person.invitestatus.name if person.invitestatus
end

node :acceptance_status do |person|
    person.acceptance_status.name if person.acceptance_status
end

node :pseudonym do |person|
    if person.pseudonym
        person.pseudonym.first_name + ' ' + person.pseudonym.last_name
    else
        ''
    end
end
