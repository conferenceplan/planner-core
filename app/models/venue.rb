class Venue < ActiveRecord::Base
  attr_accessible :lock_version, :name, :sort_order#, :postal_address

  include RankedModel
  ranks :sort_order

  default_scope {order('venues.sort_order asc')}
  
  has_many  :rooms, :dependent => :destroy
  validates_presence_of :name

  audited :allow_mass_assignment => true

  has_one :publication, :foreign_key => :original_id, :as => :original
  has_one :published, :through => :publication,
          :source => :published,
          :source_type => 'PublishedVenue'

  has_one :address, :dependent => :delete
  has_one :postal_address, :through => :address,
          :source => :addressable, 
          :source_type => 'PostalAddress'

  accepts_nested_attributes_for :postal_address

  def self.with_geocoded_address
    joins(:postal_address).where("postal_addresses.latitude is not null and postal_addresses.longitude is not null").uniq
  end

end
