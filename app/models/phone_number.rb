class PhoneNumber < ActiveRecord::Base
  attr_accessible :lock_version, :number, :phone_type_id
  
  audited :allow_mass_assignment => true

  has_many :addresses, :as => :addressable
  has_many :people, :through => :addresses,
            :source => :addressable,
            :source_type => 'PhoneNumber'
  
  has_enumerated :phone_type, :class_name => 'PhoneTypes'
end
