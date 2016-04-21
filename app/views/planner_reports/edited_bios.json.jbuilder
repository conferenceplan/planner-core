
json.totalpages 1
json.currpage 1
    
json.rowdata @editedBios do |e|

    json.name               e.person.getFullPublicationName
    json.company            e.person.company
    json.bio                e.bio
    json.website            e.website ? e.website : ''
    json.twitterinfo        e.twitterinfo ? e.twitterinfo : ''
    json.othersocialmedia   e.othersocialmedia ? e.othersocialmedia : ''
    if e.person.bio_image && e.person.bio_image.bio_picture.url
        json.photourl           get_base_image_url + e.person.bio_image.bio_picture.url.partition(/upload/)[2]
    else
        json.photourl           e.photourl ? e.photourl : ''
    end

    json.facebook           e.facebook ? e.facebook : ''
    
end
