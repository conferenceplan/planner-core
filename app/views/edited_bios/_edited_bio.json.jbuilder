
json.survey_bio @surveyBio
if @editedBio
    json.id @editedBio.id
    json.lock_version @editedBio.lock_version
    json.bio @editedBio.bio
    json.photourl @editedBio.photourl
    json.partial! "shared/sociable_attributes", object: @editedBio
end
