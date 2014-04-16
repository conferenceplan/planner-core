class PostalAddress < ActiveRecord::Base
  attr_accessible :lock_version, :line1, :line2, :line3, :city, :state, :postcode, :country, :isdefault

  audited :allow_mass_assignment => true

  has_many :addresses, :as => :addressable
  has_many :people, :through => :addresses,
            :source => :addressable,
            :source_type => 'PostalAddress'
#  validates_presence_of :line1
end
