
json.id         person.id    
json.name       person.getFullPublicationName    
json.bio        person.bio
if person.edited_bio
    json.links do
        json.photo      person.edited_bio.photourl if person.edited_bio.photourl && person.edited_bio.photourl.length > 0
        json.url        person.edited_bio.website if person.edited_bio.website && person.edited_bio.website.length > 0
        json.twitter    person.edited_bio.twitterinfo if person.edited_bio.twitterinfo && person.edited_bio.twitterinfo.length > 0
        json.fb         person.edited_bio.facebook if person.edited_bio.facebook && person.edited_bio.facebook.length > 0
    end
end
json.prog       person.published_programme_items.collect{|i| i.id}
