
json.survey_bio @surveyBio
if @editedBio
    json.id @editedBio.id
    json.lock_version @editedBio.lock_version
    json.bio @editedBio.bio
    json.facebook @editedBio.facebook
    json.othersocialmedia @editedBio.othersocialmedia
    json.photourl @editedBio.photourl
    json.twitterinfo @editedBio.twitterinfo
    json.website @editedBio.website
end
