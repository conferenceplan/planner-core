class PostalAddress < ActiveRecord::Base
  has_many :addresses, :as => :addressable
  has_many :people, :through => :addresses

#  , :as => :addressable
#  has_many :people, :through => :addresses
end
