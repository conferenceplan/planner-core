class EmailAddress < ActiveRecord::Base
  attr_accessible :lock_version, :isdefault, :email
#  has_many :addresses, :as => :addressable
#  has_many :people, :through => :addresses
  audited :allow_mass_assignment => true

  has_many :addresses, as: :addressable
  has_many :people, through: :addresses
end
