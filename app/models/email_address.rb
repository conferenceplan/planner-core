class EmailAddress < ActiveRecord::Base
#  has_many :addresses, :as => :addressable
#  has_many :people, :through => :addresses
  acts_as_audited :parent => :address
end
