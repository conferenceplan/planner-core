class PostalAddress < ActiveRecord::Base
  attr_accessible :lock_version, :line1, :line2, :line3, :city, :state, :postcode, :country, :isdefault

  audited :allow_mass_assignment => true

  has_many :addresses, :as => :addressable
  has_many :people, :through => :addresses,
            :source => :addressable,
            :source_type => 'PostalAddress'

  geocoded_by :full_street_address
  
  after_validation :geocode, if: ->(obj){ (obj.full_street_address.length > 0) and obj.changed? }
  
  def get_latlong
    if latitude == nil && longitude == nil
      geocode
      save
    end
    
    {latitude: latitude, longitude: longitude}
  end
  
  def full_street_address
    addr = ''
    addr += line1 if line1
    addr += ', '  if city && addr.length > 0
    addr += city if city
    addr += ', '  if state && addr.length > 0
    addr += state  if state
    addr += ', '  if postcode && addr.length > 0
    addr += postcode  if postcode
    addr += ', '  if country && addr.length > 0
    addr += country  if country
    addr
  end

end
