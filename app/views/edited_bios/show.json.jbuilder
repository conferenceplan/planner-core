
json.survey_bio @surveyBio
if @editedBio
    json.id @editedBio.id
    json.lock_version @editedBio.lock_version
    json.bio @editedBio.bio
    json.facebook @editedBio.facebookid
    json.othersocialmedia @editedBio.othersocialmedia
    json.photourl @editedBio.photourl
    json.twitterinfo @editedBio.twitterid
    json.website @editedBio.website_url
end
