class EditedBio < ActiveRecord::Base
  attr_accessible :lock_version, :person_id, :bio, :photourl, :website
  belongs_to  :person 

  has_social_media :facebook, :twitterinfo, :linkedin, :youtube, :twitch, :instagram, :flickr, :reddit, :othersocialmedia

  audited :associated_with => :person, :allow_mass_assignment => true

  def website_url
    fix_url(website)
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
