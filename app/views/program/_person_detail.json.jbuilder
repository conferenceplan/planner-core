
json.id         person.id    
json.name       person.getFullPublicationNameSansPrefix
json.prefix     person.prefix    
json.bio        person.bio ? person.bio : ''
json.company    person.company
json.job_title  person.job_title
if person.edited_bio
    json.links do
        json.url        person.edited_bio.website_url if person.edited_bio.website && person.edited_bio.website.strip.length > 0
        json.partial! "shared/sociable_attributes", object: person.edited_bio
    end
end
if person.bio_image && @partition_val
    listImage = person.bio_image
    listImage.scale = @scale
    json.list_image     listImage.
            bio_picture.list.url({version: listImage.lock_version}).
            partition(@partition_val)[2] if listImage.bio_picture.list.url
    json.detail_image   listImage.bio_picture.detail.url({version: listImage.lock_version}).partition(@partition_val)[2] if listImage.bio_picture.detail.url
    json.full_image     listImage.bio_picture.standard.url({version: listImage.lock_version}).partition(@partition_val)[2] if listImage.bio_picture.standard.url

    json.image_256_url (get_base_image_url + listImage.bio_picture.square256.url({version: listImage.lock_version}).partition(@partition_val)[2]) if listImage.bio_picture.square256.url
end
json.prog       person.published_programme_items.only_public.collect{|i| i.id}
