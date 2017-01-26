class EditedBio < ActiveRecord::Base
  attr_accessible :lock_version, :bio, :website, :twitterinfo, :othersocialmedia, :photourl, :facebook, :person_id, :linkedin, :youtube, :twitch, :instagram, :flickr, :reddit
  belongs_to  :person 

# https://www.linkedin.com/in - for linkedin URL

  audited :associated_with => :person, :allow_mass_assignment => true
  
  def twitterid
    /[^\/|^@]+$/.match(twitterinfo.gsub(/\/+$/,'')).to_s
  end
  
  def facebookid
    /[^\/|^@]+$/.match(facebook.gsub(/\/+$/,'')).to_s
  end
  
  def linkedinid
    /[^\/|^@]+$/.match(linkedin.gsub(/\/+$/,'')).to_s
  end

  def youtubeid
    /[^\/|^@]+$/.match(youtube.gsub(/\/+$/,'')).to_s
  end

  def twitchid
    /[^\/|^@]+$/.match(twitch.gsub(/\/+$/,'')).to_s
  end

  def instagramid
    /[^\/|^@]+$/.match(instagram.gsub(/\/+$/,'')).to_s
  end

  def flickrid
    /[^\/|^@]+$/.match(flickr.gsub(/\/+$/,'')).to_s
  end

  def redditid
    /[^\/|^@]+$/.match(reddit.gsub(/\/+$/,'')).to_s
  end
  
  def website_url
    fix_url(website)
  end

  def has_social_media?
    website.present? || othersocialmedia.present? || twitterinfo.present? || facebook.present? || linkedin.present? || youtube.present? || twitch.present? || instagram.present? || flickr.present? || reddit.present?
  end

  protected
  def fix_url(url)
    if url
      res = url.strip # remove trailing and preceding whitespace
      
      # Add the protocol if not alreay present
      if !res.blank?
        unless res[/\Ahttp:\/\//] || res[/\Ahttps:\/\//]
          res = "http://#{res}"
        end
      end
      
      res
    else
      url
    end
  end

end
