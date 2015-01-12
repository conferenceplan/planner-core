class EditedBio < ActiveRecord::Base
  attr_accessible :lock_version, :bio, :website, :twitterinfo, :othersocialmedia, :photourl, :facebook, :person_id
  belongs_to  :person 

  audited :associated_with => :person, :allow_mass_assignment => true
  
  def twitterid
    /[^\/|^@]+$/.match(twitterinfo).to_s
  end
  
  def facebookid
    /[^\/|^@]+$/.match(facebook).to_s
  end
  
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
