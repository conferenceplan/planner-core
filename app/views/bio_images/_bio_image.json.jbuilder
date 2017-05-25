if img
  json.id img.id

  json.bio_picture do
    json.url img.bio_picture.url({version: img.lock_version})
    
      img.bio_picture.versions.each do |pic|
        json.set! pic[0] do
          json.url pic[1].url({version: img.lock_version})
        end
      end
  end

  json.person_id      img.person_id
  json.created_at     img.created_at
  json.updated_at     img.updated_at
  json.lock_version   img.lock_version
end
