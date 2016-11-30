class PostalAddress < ActiveRecord::Base
  attr_accessible :lock_version, :line1, :line2, :line3, :city, :state, :postcode, :country, :isdefault, :latitude, :longitude,
                  :state_code, :country_code

  audited :allow_mass_assignment => true

  has_many :addresses, :as => :addressable
  has_many :people, :through => :addresses,
            :source => :addressable,
            :source_type => 'PostalAddress'

  geocoded_by :full_street_address
  
  after_save :check_default
  before_save :state_and_country_from_code

  after_validation :geocode, if: ->(obj){ (obj.full_street_address.present?) and obj.changed? and can_geocode_address }
  
  def get_latlong
    if latitude == nil && longitude == nil && full_street_address.present?
      geocode
      save
    end
    
    {lat: latitude, lng: longitude}
  end
  
  def can_geocode_address
    full_street_address.present?
  end
  
  def full_street_address
    [line1, city, state, postcode, country].compact.join(', ')
  end

  def check_default
    if self.isdefault # if this is the default then make the others non default (for the person)
      self.addresses.each do |address|
        PostalAddress.joins(:addresses).where(['addresses.person_id = ? && postal_addresses.id != ?', address.person_id, self.id]).update_all("postal_addresses.isdefault = 0")
      end
    end
  end
  
  def state_and_country_from_code
    if !self.country_changed? || self.country.blank?
      if !self.country_code.blank?
        c = ISO3166::Country.new(self.country_code)
        self.country = c.name if c
      end
    end

    if !self.state_changed? || self.state.blank? || self.state_code_changed?
      if !self.state_code.blank?
        s = ISO3166::Country.new(self.country_code).states[self.state_code] if !self.country_code.blank?
        self.state = s["name"] if s
      end
    end
  end

end
