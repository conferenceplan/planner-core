#
#
#
json.array! @people.each do |person|
    
    json.id         person.id
    json.name       person.getFullPublicationName
    if @peopleIds != nil
        json.bio        person.bio ? person.bio : ''
        if person.edited_bio
            json.website    person.edited_bio.website if person.edited_bio.website && person.edited_bio.website.length > 0
            json.twitter    person.edited_bio.twitterinfo if person.edited_bio.twitterinfo && person.edited_bio.twitterinfo.length > 0
            json.fb         person.edited_bio.facebook if person.edited_bio.facebook && person.edited_bio.facebook.length > 0
            json.other_url  person.edited_bio.othersocialmedia if person.edited_bio.othersocialmedia && person.edited_bio.othersocialmedia.length > 0
        end
        if person.bio_image && @partition_val
            listImage = person.bio_image
            listImage.scale = @scale
            json.list_image     @cloudinaryURI + listImage.bio_picture.list.url.partition(@partition_val)[2]
            json.detail_image   @cloudinaryURI + listImage.bio_picture.detail.url.partition(@partition_val)[2]
            json.full_image     @cloudinaryURI + listImage.bio_picture.standard.url.partition(@partition_val)[2]
        end
    end
    
end
