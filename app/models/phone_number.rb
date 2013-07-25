class PhoneNumber < ActiveRecord::Base
  audited :allow_mass_assignment => true

  has_many :addresses, :as => :addressable
  has_many :people, :through => :addresses,
            :source => :addressable,
            :source_type => 'PhoneNumber'
  
  has_enumerated :phone_type, :class_name => 'PhoneTypes'
end
