class PostalAddress < ActiveRecord::Base
  has_many :addresses, :as => :addressable
  has_many :people, :through => :addresses,
            :source => :addressable,
            :source_type => 'PostalAddress'
#  validates_presence_of :line1
end
