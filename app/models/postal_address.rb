class PostalAddress < ActiveRecord::Base

  audited :allow_mass_assignment => true

  has_many :addresses, :as => :addressable
  has_many :people, :through => :addresses,
            :source => :addressable,
            :source_type => 'PostalAddress'
#  validates_presence_of :line1
end
