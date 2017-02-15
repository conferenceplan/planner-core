
if object
  if object.respond_to?(:facebook)
    json.facebook object.facebook
    json.facebookid object.facebookid
    json.facebook_url object.facebook_url
  end
  if object.respond_to?(:twitter)
    json.twitter object.twitter
    json.twitterinfo object.twitterinfo if object.respond_to?(:twitterinfo)
    json.twitterid object.twitterid
    json.twitter_url object.twitter_url
  end
  if object.respond_to?(:linkedin)
    json.linkedin object.linkedin
    json.linkedinid object.linkedinid
    json.linkedin_url object.linkedin_url
  end
  if object.respond_to?(:youtube)
    json.youtube object.youtube
    json.youtubeid object.youtubeid
    json.youtube_url object.youtube_url
  end
  if object.respond_to?(:twitch)
    json.twitch object.twitch
    json.twitchid object.twitchid
    json.twitch_url object.twitch_url
  end
  if object.respond_to?(:instagram)
    json.instagram object.instagram
    json.instagramid object.instagramid
    json.instagram_url object.instagram_url
  end
  if object.respond_to?(:flickr)
    json.flickr object.flickr
    json.flickrid object.flickrid
    json.flickr_url object.flickr_url
  end
  if object.respond_to?(:reddit)
    json.reddit object.reddit
    json.redditid object.redditid
    json.reddit_url object.reddit_url
  end
  if object.respond_to?(:othersocialmedia)
    json.othersocialmedia object.othersocialmedia
    json.othersocialmedia_url object.othersocialmedia_url
  end
  if object.respond_to?(:website_url)
    json.website object.website_url if object.respond_to?(:website)
    json.url object.website_url if object.respond_to?(:url)
    json.website_url object.website_url
  end
  if object.respond_to?(:has_social_media?)
    json.has_social_media object.has_social_media?
  end
end