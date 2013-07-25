class EmailAddress < ActiveRecord::Base
#  has_many :addresses, :as => :addressable
#  has_many :people, :through => :addresses
  audited :allow_mass_assignment => true
end
