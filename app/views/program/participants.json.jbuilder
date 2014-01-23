
json.array! @participants.each do |person|
    json.partial! 'person_detail', person: person
end
